defmodule Castile do
  @moduledoc """
  Documentation for Castile.
  """

  alias :erlsom, as: Erlsom

  @priv_dir Application.app_dir(:castile, "priv")

  import Record
  defrecord :wsdl_definitions,       :"wsdl:tDefinitions",      [:attrs, :namespace, :name,     :docs,   :any,    :choice]
  defrecord :wsdl_service,           :"wsdl:tService",          [:attrs, :name,      :docs,     :choice, :ports]
  defrecord :wsdl_port,              :"wsdl:tPort",             [:attrs, :name,      :binding,  :docs,   :choice]
  defrecord :wsdl_binding,           :"wsdl:tBinding",          [:attrs, :binding,   :type,     :docs,   :choice, :ops]
  defrecord :wsdl_binding_operation, :"wsdl:tBindingOperation", [:attrs, :name,      :docs,     :choice, :input,  :output, :fault]
  defrecord :wsdl_import,            :"wsdl:tImport",           [:attrs, :namespace, :location, :docs]
  defrecord :soap_operation,         :"soap:tOperation",        [:attrs, :required,  :action,   :style]
  defrecord :soap_address,           :"soap:tAddress",          [:attrs, :required,  :location]

  defmodule Model do
    defstruct [:operations, :model]
    @type t :: %__MODULE__{operations: [map], model: term}
  end

  @spec init_model(String.t, prefix :: char) :: Model.t
  def init_model(wsdl_file, prefix \\ 'p') do
    wsdl = Path.join([@priv_dir, "wsdl.xsd"])
    {:ok, wsdl_model} = Erlsom.compile_xsd_file(
      Path.join([@priv_dir, "soap.xsd"]),
      prefix: 'soap',
      include_files: [{'http://schemas.xmlsoap.org/wsdl/', 'wsdl', wsdl}]
    )
    # add the xsd model
    wsdl_model = Erlsom.add_xsd_model(wsdl_model)

    include_dir = Path.dirname(wsdl_file)
    options = [dir_list: include_dir]

    # parse wsdl
    {model, operations} = parse_wsdls([wsdl_file], prefix, wsdl_model, options, {nil, []})

    # TODO: add files as required
    # now compile envelope.xsd, and add Model
    {:ok, envelope_model} = Erlsom.compile_xsd_file(Path.join([@priv_dir, "envelope.xsd"]), prefix: 'soap')
    soap_model = Erlsom.add_model(envelope_model, model)
    # TODO: detergent enables you to pass some sort of AddFiles that will stitch together the soap model
    # SoapModel2 = addModels(AddFiles, SoapModel),

    %Model{operations: operations, model: soap_model}
  end

  def parse_wsdls([], _prefix, _wsdl_model, _opts, acc), do: acc

  def parse_wsdls([path | rest], prefix, wsdl_model, opts, {acc_model, acc_operations}) do
    {:ok, wsdl_file} = get_file(String.trim(path))
    {:ok, parsed, _} = Erlsom.scan(wsdl_file, wsdl_model)
    # get xsd elements from wsdl to compile
    xsds = extract_wsdl_xsds(parsed)
    # Now we need to build a list: [{Namespace, Prefix, Xsd}, ...] for all the Xsds in the WSDL.
    # This list is used when a schema inlcudes one of the other schemas. The AXIS java2wsdl
    # generates wsdls that depend on this feature.
    import_list = Enum.map(xsds, fn xsd ->
      {:erlsom_lib.getTargetNamespaceFromXsd(xsd), nil, xsd}
    end)

    # TODO: pass the right options here
    model = add_schemas(xsds, prefix, opts, import_list, acc_model)

    ports = get_ports(parsed)
    operations = get_operations(parsed, ports)
    imports = get_imports(parsed)

    acc = {model, operations ++ acc_operations}
    # process imports (recursively, so that imports in the imported files are
    # processed as well).
    # For the moment, the namespace is ignored on operations etc.
    # this makes it a bit easier to deal with imported wsdl's.
    acc = parse_wsdls(imports, prefix, wsdl_model, opts, acc)
    parse_wsdls(rest, prefix, wsdl_model, opts, acc)
  end

  # compile each of the schemas, and add it to the model.
  # Returns Model
  # (TODO: using the same prefix for all XSDS makes no sense, generate one)
  def add_schemas(xsds, prefix, opts, imports, acc_model \\ nil) do
    Enum.reduce(xsds, acc_model, fn xsd, acc ->
      case xsd do
        nil -> acc
        _ ->
          {:ok, model} = :erlsom_compile.compile_parsed_xsd(xsd, [{:prefix, prefix}, {:include_files, imports} | opts])

          case acc_model do
            nil -> model
            _ -> :erlsom.add_model(acc_model, model)
          end
      end
    end)
  end

  def get_file(uri) do
    case URI.parse(uri) do
      %{scheme: scheme} when scheme in ["http", "https"] ->
        raise "Not implemented"
        # get_remote_file()
      _ ->
        get_local_file(uri)
    end
  end

  def get_local_file(uri) do
    File.read(uri)
  end

  def extract_wsdl_xsds(wsdl) do
    case get_toplevel_elements(wsdl, :"wsdl:tTypes") do
      [{:"wsdl:tTypes", _attrs, _docs, choice}] -> choice
      [] -> []
    end
  end

  def get_toplevel_elements(wsdl_definitions(choice: choice), type) do
    # TODO: reduce using function sigs instead
    Enum.reduce(choice, [], fn
      {:"wsdl:anyTopLevelOptionalElement", _attrs, tuple}, acc ->
        case elem(tuple, 0) do
          ^type -> [tuple | acc]
          _ -> acc
        end
      _, acc -> acc
    end)
  end

  # %% returns [#port{}]
  # %% -record(port, {service, port, binding, address}).

  #  TODO: use records everywhere
  def get_ports(parsed_wsdl) do
    services = get_toplevel_elements(parsed_wsdl, :"wsdl:tService")
    Enum.reduce(services, [], fn service, acc ->
      wsdl_service(name: service_name, ports: ports) = service
      Enum.reduce(ports, acc, fn
        wsdl_port(name: name, binding: binding, choice: choice), acc ->
          Enum.reduce(choice, acc, fn
            soap_address(location: location), acc ->
              [%{service: service_name, port: name, binding: binding, address: location} | acc]
            _, acc -> acc # non-soap bindings are ignored
          end)
          _, acc -> acc
      end)
    end)
  end

  def get_operations(parsed_wsdl, ports) do
    bindings = get_toplevel_elements(parsed_wsdl, :"wsdl:tBinding")
    Enum.reduce(bindings, [], fn (wsdl_binding(binding: binding, ops: ops), acc) ->
      Enum.reduce(ops, acc, fn (wsdl_binding_operation(name: name, choice: choice), acc) ->
        case choice do
          [soap_operation(action: action)] ->
            # lookup Binding in Ports, and create a combined result
            operations =
              ports
              |> Enum.filter(fn port -> :erlsom_lib.localName(port[:binding]) == binding end)
              |> Enum.map(fn port ->
                %{service: port.service, port: port.port, operation: name, binding: binding, address: port.address, action: action}
              end)
            operations ++ acc
          _ ->  acc
        end
      end)
    end)
  end

  def get_imports(parsed_wsdl) do
    parsed_wsdl
    |> get_toplevel_elements(:"wsdl:tImport")
    |> Enum.map(fn wsdl_import(location: location) -> to_string(location) end)
  end

  # --- Introspection --------

  defrecord :type, [:name, :tp, :els, :attrs, :anyAttr, :nillable, :nr, :nm, :mx, :mxd, :typeName]
  defrecord :el,   [:alts, :mn, :mx, :nillable, :nr]
  defrecord :alt,  [:tag, :type, :nxt, :mn, :mx, :rl, :anyInfo]
  defrecord :attr, :att, [:name, :nr, :opt, :tp]

  defrecord :erlsom_model, :model, [:types, :namespaces, :target_namespace, :type_hierarchy, :any_attribs, :value_fun]

  def convert(operation, map, %Model{model: erlsom_model(types: types), operations: ops} = model) do
    tup = cast_type(operation, map, types)
    Erlsom.write(tup, model.model, output: :binary)
  end

  #@spec convert(map) :: tuple
  def cast_type(name, map, types) do
    spec = List.keyfind(types, name, type(:name))
    IO.inspect spec

    # TODO: check type(spec, :tp) and handle other things than :sequence
    vals =
      spec
      |> type(:els)
      |> Enum.map(&convert_el(&1, map, types))
    List.to_tuple([name, [] | vals])
  end

  # TODO: will need to pass through parent type possibly
  def convert_el(el(alts: [alt(tag: tag, type: t, mn: 1, mx: 1)], mn: min, mx: max, nillable: nillable, nr: _nr), map, types) do
    case Map.get(map, tag) do
      nil ->
        if nillable == true do
          nil
        else
          raise "Non-nillable type #{tag} found nil"
        end
      val ->
        case t do
          {:"#PCDATA", :char} ->
            val
          t when is_atom(t) ->
            cast_type(t, val, types)
        end
    end
  end

end
