defmodule Castile do
  @moduledoc """
  Documentation for Castile.
  """

  @priv_dir Application.app_dir(:castile, "priv")

  import Castile.Erlsom
  import Castile.WSDL
  import Castile.SOAP

  defmodule Model do
    @doc """
    A representation of the WSDL model, containing the type XSD schema and all
    other WSDL metadata.
    """
    defstruct [:operations, :model]
    @type t :: %__MODULE__{operations: map, model: term}
  end

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
    wsdl = Path.join([@priv_dir, "wsdl.xsd"])
    {:ok, wsdl_model} = :erlsom.compile_xsd_file(
      Path.join([@priv_dir, "soap.xsd"]),
      prefix: 'soap',
      include_files: [{'http://schemas.xmlsoap.org/wsdl/', 'wsdl', wsdl}]
    )
    # add the xsd model
    wsdl_model = :erlsom.add_xsd_model(wsdl_model)

    include_dir = Path.dirname(wsdl_file)
    options = [dir_list: include_dir]

    # parse wsdl
    {model, wsdls} = parse_wsdls([wsdl_file], namespaces, wsdl_model, options, {nil, []})

    # TODO: add files as required
    # now compile envelope.xsd, and add Model
    {:ok, envelope_model} = :erlsom.compile_xsd_file(Path.join([@priv_dir, "envelope.xsd"]), prefix: 'soap')
    soap_model = :erlsom.add_model(envelope_model, model)
    # TODO: detergent enables you to pass some sort of AddFiles that will stitch together the soap model
    # SoapModel2 = addModels(AddFiles, SoapModel),

    # process wsdls
    ports = get_ports(wsdls)
    operations = get_operations(wsdls, ports, model)

    %Model{operations: operations, model: soap_model}
  end

  defp parse_wsdls([], _namespaces, _wsdl_model, _opts, acc), do: acc

  defp parse_wsdls([path | rest], namespaces, wsdl_model, opts, {acc_model, acc_wsdl}) do
    {:ok, wsdl_file} = get_file(String.trim(path))
    {:ok, parsed, _} = :erlsom.scan(wsdl_file, wsdl_model)
    # get xsd elements from wsdl to compile
    xsds = extract_wsdl_xsds(parsed)
    # Now we need to build a list: [{Namespace, Prefix, Xsd}, ...] for all the Xsds in the WSDL.
    # This list is used when a schema includes one of the other schemas. The AXIS java2wsdl
    # generates wsdls that depend on this feature.
    import_list = Enum.map(xsds, fn xsd ->
      uri = :erlsom_lib.getTargetNamespaceFromXsd(xsd)
      prefix = :proplists.get_value(uri, namespaces, :undefined)
      {uri, prefix, xsd}
    end)

    # TODO: pass the right options here
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
  # Returns Model
  defp add_schemas(xsds, opts, imports, acc_model \\ nil) do
    Enum.reduce(xsds, acc_model, fn xsd, acc ->
      case xsd do
        nil -> acc
        _ ->
          tns = :erlsom_lib.getTargetNamespaceFromXsd(xsd)
          prefix = elem(List.keyfind(imports, tns, 0), 1)
          opts = [{:prefix, prefix}, {:include_files, imports} | opts]
          {:ok, model} = :erlsom_compile.compile_parsed_xsd(xsd, opts)

          case acc_model do
            nil -> model
            _ -> :erlsom.add_model(acc_model, model)
          end
      end
    end)
  end

  defp get_file(uri) do
    case URI.parse(uri) do
      %{scheme: scheme} when scheme in ["http", "https"] ->
        raise "Not implemented"
        # get_remote_file()
      _ ->
        File.read(uri)
    end
  end

  defp extract_wsdl_xsds(wsdl_definitions(types: types)) when is_list(types) do
    types
    |> Enum.map(fn {:"wsdl:tTypes", _attrs, _docs, types} -> types end)
    |> List.flatten()
  end
  defp extract_wsdl_xsds(wsdl_definitions()), do: []

  # TODO: soap1.2

  # %% returns [#port{}]
  # %% -record(port, {service, port, binding, address}).

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
    ns = get_namespace(wsdls, uri)

    objs = elem(ns, type_pos)
    List.keyfind(objs, local, pos)
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

  defp get_imports(wsdl_definitions(imports: :undefined)), do: []
  defp get_imports(wsdl_definitions(imports: imports)) do
    Enum.map(imports, fn wsdl_import(location: location) -> location end)
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
  defp extract_type(_wsdls, model, [wsdl_part(element: el, name: name)]) do
    local = :erlsom_lib.localName(el)
    uri = :erlsom_lib.getUriFromQname(el)
    prefix = :erlsom_lib.getPrefixFromModel(model, uri)
    case prefix do
      :undefined -> local
      nil -> local
      "" -> local
      _ -> prefix <> ":" <> local
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
  def convert(%Model{model: model(types: types)} = model, operation, params) do
    get_in(model.operations, [to_string(operation), :input])
    |> resolve_element(types)
    |> cast_type(params, types)
    |> List.wrap()
    |> wrap_envelope()
    |> :erlsom.write(model.model, output: :binary)
  end

  defp resolve_element(name, types) do
    type(els: [el(alts: alts)]) = List.keyfind(types, :_document, type(:name))
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
    spec = List.keyfind(types, name, type(:name))

    # TODO: check type(spec, :tp) and handle other things than :sequence
    vals =
      spec
      |> type(:els)
      |> Enum.map(&convert_el(&1, input, types))
    List.to_tuple([name, [] | vals])
  end

  # TODO: will need to pass through parent type possibly
  defp convert_el(el(alts: [alt(tag: tag, type: t, mn: 1, mx: 1)], mn: min, mx: max, nillable: nillable, nr: _nr), map, types) do
    case Map.get(map, tag) do
      nil ->
        cond do
          min == 0          -> :undefined
          nillable == true  -> nil
          true              -> raise "Non-nillable type #{tag} found nil"
        end
      val ->
        case t do
          # val # erlsom will happily accept binaries
          {:"#PCDATA", _} ->
            val
          t when is_atom(t) ->
            cast_type(t, val, types)
        end
    end
  end

  # ---

  @doc """
  Calls a SOAP service operation.

  ## Examples

      iex> Castile.call(model, :CountryISOCode, %{sCountryName: "Netherlands"})
      {:ok, "NL"}
  """
  @spec call(wsdl :: Model.t, operation :: atom, params :: map) :: {:ok, term} | {:error, term}
  def call(%Model{model: model(types: types)} = model, operation, params \\ %{}) do
    op = model.operations[to_string(operation)]
    {:ok, params} = convert(model, operation, params)

    # http call
    headers =  [{"Content-Type", "text/xml; encoding=utf-8"}, {"SOAPAction", op.action}]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.post(op.address, params, headers)
    # TODO: check content type for multipart
    # TODO: handle response headers
    {:ok, resp, []} = :erlsom.scan(body, model.model, output_encoding: :utf8)

    output = resolve_element(op.output, types)
    soap_envelope(body: soap_body(choice: [{^output, _, body}])) = resp
    # TODO parse body further into a map
    {:ok, body}
  end
end
