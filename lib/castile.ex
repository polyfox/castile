defmodule Castile do
  @moduledoc """
  Documentation for Castile.
  """

  alias :erlsom, as: Erlsom

  @priv_dir Application.app_dir(:castile, "priv")

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
    #{model, operations} = parse_wsdls([wsdl_file], prefix, wsdl_model, options)
    res = parse_wsdls([wsdl_file], prefix, wsdl_model, options, {nil, []})

    #%% parse Wsdl
    #{Model, Operations} = parseWsdls([WsdlFile], Prefix, WsdlModel2, Options, {undefined, []}),
    #%% TODO: add files as required
    #%% now compile envelope.xsd, and add Model
    #{ok, EnvelopeModel} = erlsom:compile_xsd_file(filename:join([Path, "envelope.xsd"]),
    #                      [{prefix, "soap"}]),
    #SoapModel = erlsom:add_model(EnvelopeModel, Model),
    #SoapModel2 = addModels(AddFiles, SoapModel),
    ##wsdl{operations = Operations, model = SoapModel2}.
  end

  # parseWsdls([WsdlFile | Tail], Prefix, WsdlModel, Options, {AccModel, AccOperations}) ->
  def parse_wsdls([path | rest], prefix, wsdl_model, opts, {acc_model, acc_operations}) do
    {:ok, wsdl_file} = get_file(String.trim(path))
    {:ok, parsed, _} = :erlsom.scan(wsdl_file, wsdl_model)
    # get xsd elements from wsdl to compile
    xsds = extract_wsdl_xsds(parsed)
    # Now we need to build a list: [{Namespace, Prefix, Xsd}, ...] for all the Xsds in the WSDL.
    # This list is used when a schema inlcudes one of the other schemas. The AXIS java2wsdl
    # generates wsdls that depend on this feature.
    imports = Enum.map(xsds, fn xsd ->
      {:erlsom_lib.getTargetNamespaceFromXsd(xsd), nil, xsd}
    end)

    # TODO: pass the right options here
    model = add_schemas(xsds, prefix, opts, imports, acc_model)

    # Ports = getPorts(ParsedWsdl),
    # Operations = getOperations(ParsedWsdl, Ports),
    # Imports = getImports(ParsedWsdl),
    # Acc2 = {Model2, Operations ++ AccOperations},
    # %% process imports (recursively, so that imports in the imported files are
    # %% processed as well).
    # %% For the moment, the namespace is ignored on operations etc.
    # %% this makes it a bit easier to deal with imported wsdl's.
    # Acc3 = parseWsdls(Imports, Prefix, WsdlModel, Options, Acc2),
    # parseWsdls(Tail, Prefix, WsdlModel, Options, Acc3).
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
      %{scheme: scheme} when scheme in [:http, :https] ->
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
      [] -> nil
    end
  end

  def get_toplevel_elements({:"wsdl:tDefinitions", _attrs, _namespace, _name, _docs, _any, choice}, type) do
    # TODO: reduce using function sigs instead
    Enum.reduce(choice, [], fn
      {:"wsdl:anyTopLevelOptionalElement", _attrs, tuple}, acc ->
        IO.puts "in there"
        IO.inspect tuple
        case elem(tuple, 0) do
          ^type -> [tuple | acc]
          _ -> acc
        end
      _, acc -> acc
    end)
  end
end
