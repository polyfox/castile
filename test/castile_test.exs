defmodule CastileTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  #doctest Castile

  setup_all do
    HTTPoison.start
  end

  setup do
    path = Path.expand("fixtures/vcr_cassettes", __DIR__)
    ExVCR.Config.cassette_library_dir(path)
    :ok
  end

  test "init_model" do
    path = Path.expand("fixtures/wsdls/example.wsdl", __DIR__)
    model = Castile.init_model(path)

    assert Map.has_key?(model.operations, "store")
    assert Map.has_key?(model.operations, "retrieve")
    {:ok, xml} = Castile.convert(model, :contact, %{
      id: 10,
      first_name: "John",
      last_name: "Doe",
      projects: ["First project", "Second project"]
    })
    assert xml == ~s(<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><erlsom:contact xmlns:erlsom="http://example.com/contacts.xsd"><id>10</id><first_name>John</first_name><last_name>Doe</last_name><projects>First project</projects><projects>Second project</projects></erlsom:contact></soap:Body></soap:Envelope>)
  end

  describe "document/literal" do
    test "CountryInfoService" do
      use_cassette "CountryInfoService" do
        path = Path.expand("fixtures/wsdls/CountryInfoService.wsdl", __DIR__)
        model = Castile.init_model(path)
        {:ok, resp} = Castile.call(model, :CountryISOCode, %{sCountryName: "Netherlands"})
        assert resp == "NL"
      end
    end

    test "CountryInfoService_complex" do
      use_cassette "CountryInfoService_complex" do
        path = Path.expand("fixtures/wsdls/CountryInfoService.wsdl", __DIR__)
        model = Castile.init_model(path)
        {:ok, resp} = Castile.call(model, :ListOfCountryNamesGroupedByContinent)
	resp = List.first(resp[:tCountryCodeAndNameGroupedByContinent])
        assert get_in(resp, [:Continent, :sCode]) == "AF"
      end
    end

    test "BLZService" do
      use_cassette "BLZService" do
        path = Path.expand("fixtures/wsdls/BLZService.wsdl", __DIR__)
        model = Castile.init_model(path)
        {:ok, resp} = Castile.call(model, :getBank, %{blz: "70070010"})
        assert resp == %{
              bezeichnung: "Deutsche Bank",
              bic: "DEUTDEMMXXX",
              ort: "München",
              plz: "80271"
            }
      end
    end

    test "StatsService" do
      use_cassette "StatsService" do
        params = %{
          viewSettings: %{
            rollingPeriod: "Minutes30",
            shiftStart: 28_800_000,
            statisticsRange: "CurrentWeek",
            timeZone: -25_200_000
          }
        }

        path = Path.expand("fixtures/wsdls/StatsService.wsdl", __DIR__)
        model = Castile.init_model(path)
        assert {:ok, %{}} = Castile.call(model, :setSessionParameters, params)
      end
    end

    test "RATP" do
    end

    test "faults" do
      use_cassette "europepmc" do
        path = Path.expand("fixtures/wsdls/europepmc.wsdl", __DIR__)
        model = Castile.init_model(path)
        {:error, fault} = Castile.call(model, :searchPublications, %{
          queryString: "7",
          resultType: "nonexistent"
        })

        assert fault == %Castile.Fault{detail: nil, faultactor: nil, faultcode: "http://schemas.xmlsoap.org/soap/envelope/", faultstring: "Cannot find dispatch method for {https://www.europepmc.org/data}searchPublications"}
      end
    end
  end
end
