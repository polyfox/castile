defmodule Castile.Models do
  @moduledoc """
  Model WSDL parser functions.
  """

  import Castile.Records.{WSDL, SOAP}

  alias Castile.Meta.{Helper, Model}

  @spec init(Path.t(), namespaces :: list) :: Model.t()
  def init(wsdl_file, namespaces \\ []) do
    priv_dir = Application.app_dir(:castile, "priv")
    wsdl = Path.join([priv_dir, "wsdl.xsd"])

    {:ok, wsdl_model} =
      :erlsom.compile_xsd_file(
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

    model = Helper.overwrite_prefix(model)

    # now compile envelope.xsd, and add Model
    {:ok, envelope_model} =
      :erlsom.compile_xsd_file(Path.join([priv_dir, "envelope.xsd"]), prefix: 'soap', strict: true)

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
    import_list =
      Enum.reduce(xsds, [], fn xsd, acc ->
        uri = :erlsom_lib.getTargetNamespaceFromXsd(xsd)

        case uri do
          :undefined ->
            acc

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

  defp get_file(uri, opts) do
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

  # compile each of the schemas, and add it to the model.
  defp add_schemas(xsds, opts, imports, acc_model) do
    {model, _} =
      Enum.reduce(Enum.reject(xsds, &is_nil/1), {acc_model, []}, fn xsd, {acc, imported} ->
        tns = :erlsom_lib.getTargetNamespaceFromXsd(xsd)

        prefix =
          case List.keyfind(imports, tns, 0) do
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

        model =
          case acc_model do
            nil -> model
            _ -> :erlsom.add_model(acc, model)
          end

        {model, [{tns, prefix} | imported]}
      end)

    model
  end

  defp get_imports(wsdl_definitions(imports: :undefined)), do: []

  defp get_imports(wsdl_definitions(imports: imports)) do
    Enum.map(imports, fn wsdl_import(location: location) -> to_string(location) end)
  end

  defp get_ports(wsdls) do
    Enum.reduce(wsdls, [], fn
      wsdl_definitions(services: services), acc when is_list(services) ->
        Enum.reduce(services, acc, fn service, acc ->
          wsdl_service(name: service_name, ports: ports) = service
          # TODO: ensure ports not :undefined
          Enum.reduce(ports, acc, fn
            wsdl_port(name: name, binding: binding, choice: choice), acc when is_list(choice) ->
              Enum.reduce(choice, acc, fn
                soap_address(location: location), acc ->
                  [
                    %{
                      service: to_string(service_name),
                      port: to_string(name),
                      binding: binding,
                      address: to_string(location)
                    }
                    | acc
                  ]

                # non-soap bindings are ignored
                _, acc ->
                  acc
              end)

            _, acc ->
              acc
          end)
        end)

      _, acc ->
        acc
    end)
  end

  # get service -> port --> binding --> portType -> operation -> response-or-one-way -> param -|-|-> message
  #                     |-> bindingOperation --> message
  defp get_operations(wsdls, ports, model) do
    Enum.reduce(ports, %{}, fn %{binding: binding} = port, acc ->
      bind = get_node(wsdls, binding, wsdl_definitions(:bindings), wsdl_binding(:name))
      wsdl_binding(ops: ops, type: pt) = bind

      Enum.reduce(ops, acc, fn wsdl_binding_operation(name: name, choice: choice), acc ->
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
              output: extract_type(wsdls, model, output)
              # fault: extract_type(wsdls, model, fault) TODO
            })

          _ ->
            acc
        end
      end)
    end)
  end

  # TODO: having to say pos outside of the func is nasty but meh.
  defp get_node(wsdls, qname, type_pos, pos) do
    uri = :erlsom_lib.getUriFromQname(qname)
    local = :erlsom_lib.localName(qname)

    wsdls
    |> get_namespace(uri)
    |> elem(type_pos)
    |> List.keyfind(local, pos)
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

  defp get_namespace(wsdls, uri) when is_list(wsdls) do
    List.keyfind(wsdls, uri, wsdl_definitions(:namespace))
  end
end
