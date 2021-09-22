defmodule CastileTest do
  use ExUnit.Case
  # doctest Castile

  describe "init model" do
    test "example.wsdl" do
      path = Path.expand("fixtures/wsdls/example.wsdl", __DIR__)
      model = Castile.init_model(path)

      assert Map.has_key?(model.operations, "store")
      assert Map.has_key?(model.operations, "retrieve")

      assert {:ok, xml} =
               Castile.create_envelope(model, :store, %{
                 id: 10,
                 first_name: "John",
                 last_name: "Doe",
                 projects: ["First project", "Second project"]
               })

      assert ~s(<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><erlsom:contact xmlns:erlsom="http://example.com/contacts.xsd"><id>10</id><first_name>John</first_name><last_name>Doe</last_name><projects>First project</projects><projects>Second project</projects></erlsom:contact></soap:Body></soap:Envelope>) ==
               xml
    end

    test "CountryInfoService" do
      path = Path.expand("fixtures/wsdls/CountryInfoService.wsdl", __DIR__)
      assert %Castile.Meta.Model{operations: _operations} = model = Castile.init_model(path)

      assert {:ok, xml} = Castile.create_envelope(model, :CountryISOCode, %{sCountryName: "Netherlands"})

      assert ~s(<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><CountryISOCode xmlns=\"http://www.oorsprong.org/websamples.countryinfo\"><sCountryName>Netherlands</sCountryName></CountryISOCode></soap:Body></soap:Envelope>) ==
               xml
    end

    test "ls_ecommerce" do
      path = Path.expand("fixtures/wsdls/soap_ui_export/UCService.wsdl", __DIR__)
      model = Castile.init_model(path, [ser: "http://lsretail.com/LSOmniService/EComm/2017/Service"])

      assert Map.has_key?(model.operations, "Login")

      {:ok, xml} =
        Castile.create_envelope(model, :Login, %{
          "P:userName": "John",
          "P:password": "1234"
        })

      assert xml ==
               ~s(<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><P:Login xmlns:P=\"http://lsretail.com/LSOmniService/Loy/2021\"><P:userName>John</P:userName><P:password>1234</P:password></P:Login></soap:Body></soap:Envelope>)
    end
  end

  describe "XML body parser" do
    @body ~s(<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\r\n  <soap:Body>\r\n    <m:CountryISOCodeResponse xmlns:m=\"http://www.oorsprong.org/websamples.countryinfo\">\r\n      <m:CountryISOCodeResult>NL</m:CountryISOCodeResult>\r\n    </m:CountryISOCodeResponse>\r\n  </soap:Body>\r\n</soap:Envelope>)
    test "parse iso code response" do
      path = Path.expand("fixtures/wsdls/CountryInfoService.wsdl", __DIR__)
      model = Castile.init_model(path)

      assert {:ok, "NL"} == Castile.parse_response(model, :CountryISOCode, @body)
    end
  end
end
