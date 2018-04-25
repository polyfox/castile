defmodule CastileTest do
  use ExUnit.Case
  #doctest Castile

  test "init_model" do
    path = Path.expand("fixtures/example.wsdl", __DIR__)
    model = Castile.init_model(path)

    assert Map.has_key?(model.operations, "store")
    assert Map.has_key?(model.operations, "retrieve")

    {:ok, xml} = Castile.convert(model, :store, %{
      id: 10,
      first_name: "John",
      last_name: "Doe",
      projects: ["First project", "Second project"]
    })
    assert xml == ~s(<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><erlsom:contact xmlns:erlsom="http://example.com/contacts.xsd"><id>10</id><first_name>John</first_name><last_name>Doe</last_name><projects>First project</projects><projects>Second project</projects></erlsom:contact></soap:Body></soap:Envelope>)
  end
end
