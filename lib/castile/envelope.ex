defmodule Castile.Envelope do
  @moduledoc """
  Creates a xml envelope
  """

  import Castile.Records.{Erlsom, SOAP}

  alias Castile.Meta.Model

  @spec create(Castile.Meta.Model.t(), any, map) ::
          {:error, [1..255, ...]}
          | {:ok,
             binary
             | list
             | {:error, binary | list,
                binary
                | maybe_improper_list(
                    binary | maybe_improper_list(any, binary | []) | char,
                    binary | []
                  )}
             | {:incomplete, binary | list, binary}}
  def create(%Model{model: model(types: types)} = model, operation, params \\ %{}) do
    model.operations[to_string(operation)]
    |> Map.get(:input)
    |> resolve_element(types)
    |> cast_type(params, types)
    |> List.wrap()
    |> wrap_envelope()
    |> :erlsom.write(model.model, output: :binary)
  end

  def resolve_element(nil, _types), do: nil

  def resolve_element(name, types) do
    type(els: [el(alts: alts)]) = get_type(types, :_document)

    alts
    |> List.keyfind(name, alt(:tag))
    |> alt(:type)
  end

  def get_type(types, name) when is_list(types) do
    List.keyfind(types, name, type(:name))
  end

  @spec cast_type(name :: atom, input :: map, types :: term) :: tuple
  defp cast_type(name, input, types) do
    type(els: els) = get_type(types, name)

    # TODO: check type(spec, :tp) and handle other things than :sequence
    vals = Enum.map(els, &convert_el(&1, input, types))
    List.to_tuple([name, [] | vals])
  end

  defp convert_el(
         el(
           alts: [alt(tag: tag, type: t, mn: 1, mx: 1)],
           mn: min,
           mx: _max,
           nillable: nillable,
           nr: _nr
         ),
         value,
         types
       ) do
    conv = fn
      nil ->
        cond do
          min == 0 -> :undefined
          nillable == true -> nil
          true -> raise "Non-nillable type #{tag} found nil"
        end

      val ->
        case t do
          {:"#PCDATA", _} ->
            # erlsom will cast these
            val

          t when is_atom(t) ->
            cast_type(t, val, types)
        end
    end

    case value do
      v when is_list(v) -> Enum.map(v, fn v -> conv.(Map.get(v, tag)) end)
      v when is_map(v) -> conv.(Map.get(v, tag))
    end
  end

  @spec wrap_envelope(messages :: list, headers :: list) :: term
  defp wrap_envelope(messages, headers \\ [])

  defp wrap_envelope(messages, headers) when is_list(messages) do
    soap_envelope(body: soap_body(choice: messages), header: soap_header(choice: headers))
  end
end
