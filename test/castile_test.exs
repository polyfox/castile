defmodule CastileTest do
  use ExUnit.Case
  doctest Castile

  test "init_model" do
    path = Path.expand("fixtures/example.wsdl", __DIR__)
    model = Castile.init_model(path)

    IO.inspect model
    assert model
    assert Map.has_key?(model.operations, "store")
    assert Map.has_key?(model.operations, "retrieve")

    {:ok, xml} = Castile.convert(model, :store, %{
      id: 10,
      first_name: "John",
      last_name: "Doe",
      projects: ["First project", "Second project"]
    })
    IO.puts xml
  end
end
