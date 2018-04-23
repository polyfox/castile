defmodule CastileTest do
  use ExUnit.Case
  doctest Castile

  test "init_model" do
    path = Path.expand("fixtures/example.wsdl", __DIR__)
    model = Castile.init_model(path)

    assert model
    assert Map.has_key?(model.operations, "store")
    assert Map.has_key?(model.operations, "retrieve")
  end
end
