defmodule Castile.Response do
  @moduledoc """
  Parse an xml response
  """

  import Castile.Records.{Erlsom, SOAP}

  alias Castile.Envelope
  alias Castile.Meta.Model

  @spec parse(Castile.Meta.Model.t(), Atom.t(), String.t()) :: {:ok, any}
  def parse(%Model{model: model(types: types)} = model, operation, body) do
    op = model.operations[to_string(operation)]
    {:ok, resp, _} = :erlsom.scan(body, model.model, output_encoding: :utf8)
    output = Envelope.resolve_element(op.output, types)

    case resp do
      soap_envelope(body: soap_body(choice: [{^output, _, inner_body}])) ->
        # parse body further into a map
        {:ok, transform(inner_body, types)}

      soap_envelope(body: soap_body(choice: [{^output, _}])) ->
        # Response body is empty
        # skip parsing and return an empty map.
        {:ok, %{}}
    end
  end

  defp transform(soap_fault() = fault, types) do
    params =
      Enum.into(soap_fault(fault), %{}, fn
        {k, qname() = qname} -> {k, to_string(:erlsom_lib.getUriFromQname(qname))}
        {k, :undefined} -> {k, nil}
        {k, v} -> {k, transform(v, types)}
      end)

    struct(Fault, params)
  end

  defp transform(val, types) when is_tuple(val) do
    type(els: els) = Envelope.get_type(types, elem(val, 0))

    # TODO if max unbounded, then instead of skipping it, use []
    Enum.reduce(els, %{}, fn el(
                               alts: [alt(tag: tag, type: t, mn: 1, mx: 1)],
                               mn: _min,
                               mx: _max,
                               nillable: nillable,
                               nr: pos
                             ),
                             acc ->
      val = elem(val, pos - 1)

      val =
        case t do
          {:"#PRCDATA", _} ->
            val

          # TODO: improve the layout, %{key: %{:"#any" => %{ data }} is a bit redundant if there's only any
          :any ->
            val

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
