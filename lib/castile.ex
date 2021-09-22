defmodule Castile do
  @moduledoc """
  Documentation for Castile.
  """
  import Castile.Records.{Erlsom, SOAP}

  alias Castile.Meta.{Fault, Model}
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
  defdelegate init_model(wsdl_file, namespaces \\ []), to: Castile.Models, as: :init

  def parse(%Model{model: model(types: types)} = model, operation, body) do
    op = model.operations[to_string(operation)]
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
  end


  defp get_type(types, name) when is_list(types) do
    List.keyfind(types, name, type(:name))
  end


  @doc """
  Converts an operation's parameters into XML.

  ## Examples

      iex> Castile.call(model, :CountryISOCode, %{sCountryName: "Netherlands"})
      {:ok, "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><CountryISOCode xmlns=\"http://www.oorsprong.org/websamples.countryinfo\"><sCountryName>Netherlands</sCountryName></CountryISOCode></soap:Body></soap:Envelope>"}
  """
  def convert(%Model{model: model(types: types)} = model, operation, params \\ %{}) do
    model.operations[to_string(operation)]
    |> Map.get(:input)
    |> resolve_element(types)
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
    Enum.reduce(els, %{}, fn el(alts: [alt(tag: tag, type: t, mn: 1, mx: 1)], mn: _min, mx: _max, nillable: nillable, nr: pos), acc ->
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
