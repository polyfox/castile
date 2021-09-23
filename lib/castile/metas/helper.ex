defmodule Castile.Meta.Helper do
  @moduledoc """
  Override erlsom default prefix ('P') with a custom prefix.

  For some reason the ls ecommerce wsdl and soap files don't have a valid prefix for erlsom.
  Erlsom overwrites the not existing prefix in https://github.com/willemdj/erlsom/blob/master/src/erlsom_lib.erl#L360.

  This helper does a manual overwrite if you specify an `:overwrite_prefix` in your `config.exs` file.
  """

  import Castile.Records.{Erlsom, SOAP}

  @overwrite_prefix_key :overwrite_prefix
  @overwrite_namespace_key :overwrite_namespace
  @default_erlsom_prefix 'P'

  @spec overwrite_prefix({:model, any, any, any, any, any, any}) ::
          {:model, list, list, any, any, any, any}
  def overwrite_prefix(model() = model_to_overwrite) do
    get_overwrite_prefix()
    |> start_overwrite(model_to_overwrite)
  end

  defp start_overwrite(nil, org_model), do: org_model

  defp start_overwrite(_prefix, org_model) do
    model(org_model,
      types: overwrite_type(org_model),
      namespaces: overwrite_namespace(org_model)
    )
  end

  defp overwrite_namespace(model(namespaces: namespaces)) do
    namespaces
    |> Enum.map(&cast_namespace(&1, get_overwrite_namespace()))
    |> Enum.uniq() # Delete duplicated namespaces
  end

  defp cast_namespace(ns(uri: _uri, prefix: prefix, element_form_default: _x) = ns_element, nil) do
    ns(ns_element, prefix: overwrite(prefix))
  end

  # Overwrite all namespaces with default prefixes
  defp cast_namespace(ns(uri: _uri, prefix: prefix, element_form_default: _x) = ns_element, new_namespace) when prefix == @default_erlsom_prefix do
    ns(ns_element, uri: String.to_charlist(new_namespace), prefix: overwrite(prefix))
  end

  defp cast_namespace(ns(uri: _uri, prefix: prefix, element_form_default: _x) = ns_element, _overwrite_namespace) do
    ns(ns_element, prefix: overwrite(prefix))
  end

  defp overwrite_type(model(types: types)) do
    types
    |> Enum.map(&cast_type/1)
  end

  defp cast_type(type(name: name, els: els) = type_element) do
    new_els =
      els
      |> Enum.map(&cast_el/1)

    type(type_element, name: overwrite(name), els: new_els)
  end

  defp cast_el(el(alts: alts) = el_element) do
    new_alts =
      alts
      |> Enum.map(&cast_alt/1)

    el(el_element, alts: new_alts)
  end

  defp cast_alt(alt(tag: tag, type: type, mn: 1, mx: 1) = alt_element) do
    # Set new record types
    alt(alt_element, tag: overwrite(tag), type: overwrite(type))
  end

  defp overwrite(value) do
    value
    |> do_overwrite(get_overwrite_prefix())
  end

  defp do_overwrite(value, nil), do: value

  defp do_overwrite(@default_erlsom_prefix, replace), do: Atom.to_charlist(replace)

  defp do_overwrite(value, replace) when is_atom(value) do
    value
    |> Atom.to_string()
    |> String.replace("P:", "#{replace}:")
    |> String.to_atom()
  end

  defp do_overwrite(value, _replace), do: value

  defp get_overwrite_prefix do
    :castile
    |> Application.get_env(@overwrite_prefix_key)
  end

  defp get_overwrite_namespace do
    :castile
    |> Application.get_env(@overwrite_namespace_key)
  end
end
