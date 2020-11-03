defmodule Castile do
  @moduledoc """
  Documentation for Castile.
  """
  import Castile.{Erlsom, WSDL, SOAP}

  defmodule Model do
    @doc """
    Represents the WSDL model, containing the type XSD schema and all
    other WSDL metadata.
    """
    defstruct [:operations, :model]
    @type t :: %__MODULE__{operations: map, model: term}
  end

  defmodule Fault do
    @moduledoc """
    Represents a SOAP (1.1) fault.
    """
    defexception [:detail, :faultactor, :faultcode, :faultstring]

    @type t :: %__MODULE__{
      faultcode: String.t,
      faultstring: String.t,
      faultactor: String.t,
      detail: term
    }

    def message(exception) do
      exception.faultstring
    end
  end

  # TODO: erlsom value_fun might save us the trouble of transforms on parse

  @doc """
  Initializes a service model from a WSDL file. This parses the WSDL and it's
  imports recursively, building an internal model of all the XSD types and
  SOAP metadata for later use.

  Similar to Elixir's pre-compiled Regexes, it's recommended to do this at
  compile-time in an @attribute.

  ## Examples

      iex> model = Castile.init_model("CountryInfoService.wsdl")
      %Castile.Model{...}
  """
  # TODO: take namespaces as binary
  @spec init_model(Path.t, namespaces :: list) :: Model.t
  def init_model(wsdl_file, namespaces \\ []) do
    priv_dir = Application.app_dir(:castile, "priv")
    wsdl = Path.join([priv_dir, "wsdl.xsd"])
    {:ok, wsdl_model} = :erlsom.compile_xsd_file(
      Path.join([priv_dir, "soap.xsd"]),
      prefix: 'soap',
      include_files: [{'http://schemas.xmlsoap.org/wsdl/', 'wsdl', wsdl}],
      strict: true
    )
    # add the xsd model
    wsdl_model = :erlsom.add_xsd_model(wsdl_model)

    include_dir = Path.dirname(wsdl_file)
    options = [include_dirs: [include_dir]]

    # parse wsdl
    {model, wsdls} = parse_wsdls([wsdl_file], namespaces, wsdl_model, options, {nil, []})

    # now compile envelope.xsd, and add Model
    {:ok, envelope_model} = :erlsom.compile_xsd_file(Path.join([priv_dir, "envelope.xsd"]), prefix: 'soap', strict: true)
    soap_model = :erlsom.add_model(envelope_model, model)
    # TODO: detergent enables you to pass some sort of AddFiles that will stitch together the soap model
    # SoapModel2 = addModels(AddFiles, SoapModel),

    # finally, process all wsdls at once (this solves cases where the wsdl
    # definition is split in to two files, one with types+port types, plus rest)
    ports = get_ports(wsdls)
    operations = get_operations(wsdls, ports, model)

    %Model{operations: operations, model: soap_model}
  end

  defp parse_wsdls([], _namespaces, _wsdl_model, _opts, acc), do: acc

  defp parse_wsdls([path | rest], namespaces, wsdl_model, opts, {acc_model, acc_wsdl}) do
    {:ok, wsdl_file} = get_file(String.trim(path), opts)
    {:ok, parsed, _} = :erlsom.scan(wsdl_file, wsdl_model)
    # get xsd elements from wsdl to compile
    xsds = extract_wsdl_xsds(parsed)
    # Now we need to build a list: [{Namespace, Prefix, Xsd}, ...] for all the Xsds in the WSDL.
    # This list is used when a schema includes one of the other schemas. The AXIS java2wsdl
    # generates wsdls that depend on this feature.
    import_list = Enum.reduce(xsds, [], fn xsd, acc ->
      uri = :erlsom_lib.getTargetNamespaceFromXsd(xsd)
      case uri do
        :undefined -> acc
        _ ->
          prefix = :proplists.get_value(uri, namespaces, :undefined)
          [{uri, prefix, xsd} | acc]
      end
    end)

    model = add_schemas(xsds, opts, import_list, acc_model)

    acc = {model, [parsed | acc_wsdl]}
    imports = get_imports(parsed)
    # process imports (recursively, so that imports in the imported files are
    # processed as well).
    # For the moment, the namespace is ignored on operations etc.
    # this makes it a bit easier to deal with imported wsdl's.
    acc = parse_wsdls(imports, namespaces, wsdl_model, opts, acc)
    parse_wsdls(rest, namespaces, wsdl_model, opts, acc)
  end

  # compile each of the schemas, and add it to the model.
  defp add_schemas(xsds, opts, imports, acc_model \\ nil) do
    {model, _} = Enum.reduce(Enum.reject(xsds, &is_nil/1), {acc_model, []}, fn xsd, {acc, imported} ->
      tns = :erlsom_lib.getTargetNamespaceFromXsd(xsd)
      prefix = case List.keyfind(imports, tns, 0) do
        {_, p, _} -> p
        _ -> ''
      end
      opts = [
        {:prefix, prefix},
        {:include_files, imports},
        {:already_imported, imported},
        {:strict, true}
        | opts
      ]
      {:ok, model} = :erlsom_compile.compile_parsed_xsd(xsd, opts)

      model = case acc_model do
        nil ->  model
        _ -> :erlsom.add_model(acc, model)
      end
      {model, [{tns, prefix} | imported]}
    end)
    model
  end

  defp get_file(uri, opts \\ []) do
    case URI.parse(uri) do
      %{scheme: scheme} when scheme in ["http", "https"] ->
        raise "Not implemented"
        # get_remote_file()
      _ ->
        if File.exists?(uri) do
          File.read(uri)
        else
          include = Keyword.get(opts, :include_dirs)
          find_file(uri, include)
        end
    end
  end

  defp find_file(_name, []), do: {:error, :enoent}
  defp find_file(name, [include | rest]) do
    path = Path.join([include, name])
    if File.exists?(path) do
      File.read(path)
    else
      find_file(name, rest)
    end
  end

  defp extract_wsdl_xsds(wsdl_definitions(types: types)) when is_list(types) do
    types
    |> Enum.map(fn {:"wsdl:tTypes", _attrs, _docs, types} -> types end)
    |> List.flatten()
  end
  defp extract_wsdl_xsds(wsdl_definitions()), do: []

  defp get_ports(wsdls) do
    Enum.reduce(wsdls, [], fn
      (wsdl_definitions(services: services), acc) when is_list(services) ->
        Enum.reduce(services, acc, fn service, acc ->
          wsdl_service(name: service_name, ports: ports) = service
          # TODO: ensure ports not :undefined
          Enum.reduce(ports, acc, fn
            wsdl_port(name: name, binding: binding, choice: choice), acc when is_list(choice) ->
              Enum.reduce(choice, acc, fn
                soap_address(location: location), acc ->
                  [%{service: to_string(service_name), port: to_string(name), binding: binding, address: to_string(location)} | acc]
                _, acc -> acc # non-soap bindings are ignored
              end)
              _, acc -> acc
          end)
        end)
      _, acc -> acc
    end)
  end

  # TODO: having to say pos outside of the func is nasty but meh.
  defp get_node(wsdls, qname, type_pos, pos) do
    uri   = :erlsom_lib.getUriFromQname(qname)
    local = :erlsom_lib.localName(qname)

    wsdls
    |> get_namespace(uri)
    |> elem(type_pos)
    |> List.keyfind(local, pos)
  end

  # get service -> port --> binding --> portType -> operation -> response-or-one-way -> param -|-|-> message
  #                     |-> bindingOperation --> message
  defp get_operations(wsdls, ports, model) do
    Enum.reduce(ports, %{}, fn (%{binding: binding} = port, acc) ->
      bind = get_node(wsdls, binding, wsdl_definitions(:bindings), wsdl_binding(:name))
      wsdl_binding(ops: ops, type: pt) = bind

      Enum.reduce(ops, acc, fn (wsdl_binding_operation(name: name, choice: choice), acc) ->
        case choice do
          [soap_operation(action: action)] ->
            # lookup Binding in PortType, and create a combined result
            port_type = get_node(wsdls, pt, wsdl_definitions(:port_types), wsdl_port_type(:name))
            operations = wsdl_port_type(port_type, :operations)

            operation = List.keyfind(operations, name, wsdl_operation(:name))
            params = wsdl_operation(operation, :choice)
            wsdl_request_response(input: input, output: output, fault: _fault) = params

            Map.put_new(acc, to_string(name), %{
              service: port.service,
              port: port.port,
              binding: binding,
              address: port.address,
              action: to_string(action),
              input: extract_type(wsdls, model, input),
              output: extract_type(wsdls, model, output),
              #fault: extract_type(wsdls, model, fault) TODO
            })
          _ ->  acc
        end
      end)
    end)
  end

  defp get_namespace(wsdls, uri) when is_list(wsdls) do
    List.keyfind(wsdls, uri, wsdl_definitions(:namespace))
  end

  defp get_type(types, name) when is_list(types) do
    List.keyfind(types, name, type(:name))
  end

  defp get_imports(wsdl_definitions(imports: :undefined)), do: []
  defp get_imports(wsdl_definitions(imports: imports)) do
    Enum.map(imports, fn wsdl_import(location: location) -> to_string(location) end)
  end

  defp extract_type(wsdls, model, wsdl_param(message: message)) do
    parts =
      wsdls
      |> get_node(message, wsdl_definitions(:messages), wsdl_message(:name))
      |> wsdl_message(:part)
    extract_type(wsdls, model, parts)
  end
  defp extract_type(_wsdls, _model, [wsdl_part(element: :undefined)]) do
    raise "Unhandled"
  end
  defp extract_type(_wsdls, model, [wsdl_part(element: el)]) do
    local = :erlsom_lib.localName(el)
    uri = :erlsom_lib.getUriFromQname(el)
    prefix = :erlsom_lib.getPrefixFromModel(model, uri)
    case prefix do
      :undefined -> local
      nil -> local
      "" -> local
      _ -> prefix ++ ':' ++ local
    end
    |> List.to_atom()
  end
  defp extract_type(_, _, nil), do: nil
  defp extract_type(_, _, :undefined), do: nil

  @doc """
  Converts an operation's parameters into XML.

  ## Examples

      iex> Castile.call(model, :CountryISOCode, %{sCountryName: "Netherlands"})
      {:ok, "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><CountryISOCode xmlns=\"http://www.oorsprong.org/websamples.countryinfo\"><sCountryName>Netherlands</sCountryName></CountryISOCode></soap:Body></soap:Envelope>"}
  """
  @spec convert(Model.t, operation :: atom, params :: map) :: {:ok, binary} | {:error, term}
  def convert(%Model{model: model()} = model, nil, _params) do
    []
    |> wrap_envelope()
    |> :erlsom.write(model.model, output: :binary)
  end
  def convert(%Model{model: model(types: types)} = model, type, params) do
    type
    |> cast_type(params, types)
    |> List.wrap()
    |> wrap_envelope()
    |> :erlsom.write(model.model, output: :binary)
  end

  defp resolve_element(nil, _types), do: nil
  defp resolve_element(name, types) do
    type(els: [el(alts: alts)]) = get_type(types, :_document)

    alts
    |> List.keyfind(name, alt(:tag))
    |> alt(:type)
  end

  @spec wrap_envelope(messages :: list, headers :: list) :: term
  defp wrap_envelope(messages, headers \\ [])

  defp wrap_envelope(messages, []) when is_list(messages) do
    soap_envelope(body: soap_body(choice: messages))
  end

  defp wrap_envelope(messages, headers) when is_list(messages) and is_list(headers) do
    soap_envelope(body: soap_body(choice: messages), header: soap_header(choice: headers))
  end

  @spec cast_type(name :: atom, input :: map, types :: term) :: tuple
  def cast_type(name, input, types) do
    type(els: els) = get_type(types, name)

    # TODO: check type(spec, :tp) and handle other things than :sequence
    vals = Enum.map(els, &convert_el(&1, input, types))
    List.to_tuple([name, [] | vals])
  end

  defp convert_el(el(alts: [alt(tag: tag, type: t, mn: 1, mx: 1)], mn: min, mx: max, nillable: nillable, nr: _nr), value, types) do
    conv = fn
      nil ->
        cond do
          min == 0          -> :undefined
          nillable == true  -> nil
          true              -> raise "Non-nillable type #{tag} found nil"
        end
      val ->
        case t do
          {:"#PCDATA", _} ->
            val # erlsom will cast these
          t when is_atom(t) ->
            cast_type(t, val, types)
        end
    end

    case value do
      v when is_list(v) -> Enum.map(v, fn v -> conv.(Map.get(v, tag)) end)
      v when is_map(v) -> conv.(Map.get(v, tag))
    end
  end

  @doc """
  Calls a SOAP service operation.

  ## Examples

      iex> Castile.call(model, :CountryISOCode, %{sCountryName: "Netherlands"})
      {:ok, "NL"}
  """
  @spec call(wsdl :: Model.t, operation :: atom, params :: map, headers :: list | map, opts :: list) :: {:ok, term} | {:error, %Fault{}} | {:error, term}
  def call(%Model{model: model(types: types)} = model, operation, params \\ %{}, headers \\ [], opts \\ []) do
    op = model.operations[to_string(operation)]
    input = resolve_element(op.input, types)
    {:ok, params} = convert(model, input, params)

    headers = [
      {"Content-Type", "text/xml; encoding=utf-8"},
      {"SOAPAction", op.action},
      {"User-Agent", "Castile/0.5.0"} | headers]

    case HTTPoison.post(op.address, params, headers, opts) do
      {:ok, %{status_code: 200, body: body}} ->
        # TODO: check content type for multipart
        # TODO: handle response headers
        {:ok, resp, _} = :erlsom.scan(body, model.model, output_encoding: :utf8)

        output = resolve_element(op.output, types)
        case resp do
          soap_envelope(body: soap_body(choice: [{^output, _, inner_body}])) ->
            # parse body further into a map
            {:ok, transform(inner_body, types)}
          soap_envelope(body: soap_body(choice: [{^output, _}])) ->
            # Response body is empty
            # skip parsing and return an empty map.
            {:ok, %{}}
        end
      {:ok, %{status_code: 500, body: body}} ->
        {:ok, resp, _} = :erlsom.scan(body, model.model, output_encoding: :utf8)
        soap_envelope(body: soap_body(choice: [soap_fault() = fault])) = resp
        {:error, transform(fault, types)}
    end
  end

  @doc """
  Same as call/4, but raises an exception instead.
  """
  @spec call!(wsdl :: Model.t, operation :: atom, params :: map, headers :: list | map) :: {:ok, term} | no_return()
  def call!(%Model{} = model, operation, params \\ %{}, headers \\ []) do
    case call(model, operation, params, headers) do
      {:ok, result} -> result
      {:error, fault} -> raise fault
    end
  end

  defp transform(soap_fault() = fault, types) do
    params = Enum.into(soap_fault(fault), %{}, fn
      {k, qname() = qname} -> {k, to_string(:erlsom_lib.getUriFromQname(qname))}
      {k, :undefined} -> {k, nil}
      {k, v} -> {k, transform(v, types)}
    end)
    struct(Fault, params)
  end

  defp transform(val, types) when is_tuple(val) do
    type(els: els) = get_type(types, elem(val, 0))

    # TODO if max unbounded, then instead of skipping it, use []
    Enum.reduce(els, %{}, fn el(alts: [alt(tag: tag, type: t, mn: 1, mx: 1)], mn: min, mx: max, nillable: nillable, nr: pos), acc ->
      val = elem(val, pos - 1)
      val = case t do
        {:"#PRCDATA", _} -> val
        :any -> val # TODO: improve the layout, %{key: %{:"#any" => %{ data }} is a bit redundant if there's only any
        _ ->
          # HAXX: improve
          if nillable && val == [] do
            nil
          else
            transform(val, types)
          end
      end
      Map.put(acc, tag, val)
    end)
  end
  defp transform(val, types) when is_list(val), do: Enum.map(val, &transform(&1, types))
  defp transform(:undefined, _types), do: nil
  defp transform(val, _types), do: val
end
