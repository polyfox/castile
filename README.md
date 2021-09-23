# Castile VIU Fork

# TODO VIU - LS eCommerce

- [X] Transform types the correct way: now = `:"P:Login"` expected: `:login`
- [X] Create a correct envelop
- [X] Soap UI Mock server accepts envelop and returns valid response.
- [ ] Parse XML response from mock server


Castile is a modern Elixir SOAP API client.
It borrows ideas heavily from [Detergent](https://github.com/devinus/detergent)/yaws.

Why write another SOAP client? We really wanted to use Detergent/Detergentex,
but ran into some issues (and also wanted to use HTTPoison as the HTTP client).

Detergent itself hasn't really been updated since 2013 (a time when erlang
itself had no maps even), and Detergentex being just a lightweight wrapper
around it, has the same shortcomings (even worse, the detergent version on
hex.pm that detergentex relies on has no support for HTTPS). Erlsom has also
been updated in the mean time, improving XML write speed and adding support for
binaries natively.

[Castile](https://en.wikipedia.org/wiki/Castile_soap) is an attempt at a fresh
start, with a small API that's easy to use in Elixir.

At the moment, the supported subset is SOAP 1.1 with WSDL 1.1 (and
document/literal format). SOAP 1.2 and WSDL 2.0 are on the roadmap, but none of
the APIs we interact with use either of those, so I'm having problems finding
a public API to test against (if you find one, please open an issue!).

## Installation

Install from Hex.pm:

```elixir
def deps do
  [
    {:castile, "~> 1.0"}
  ]
end
```

Docs can be found at [https://hexdocs.pm/castile](https://hexdocs.pm/castile).

## Usage

```elixir
# It's recommended to do init_model at compile time, as an @attr
@model = Castile.init_model("CountryInfoService.wsdl")

# More complex results get cast into maps:
model = Castile.init_model("BLZService.wsdl")
{:ok, resp} = Castile.call(model, :getBank, %{blz: "70070010"})
# resp => %{
#   bezeichnung: "Deutsche Bank",
#   bic: "DEUTDEMMXXX",
#   ort: "München",
#   plz: "80271"
# }
```

## LS eCommerce SOAP

### Overwrite the default erlsom prefix
Castile uses Erlang's `erlsom` lib to parse xml files. Somehow `erlosm` adds a default prefix `P:` to the types. LS eCommerce SOAP expects a `ser:` prefix.

To overwrite the default prefix you need to add a config variable.

In your `config.exs` file, add:
```Elixir
config :castile, overwrite_prefix: :ser
```

**Namespaces**

Castile will add multiple namespaces but at the end we need only one `xmlns:ser="http://lsretail.com/LSOmniService/EComm/2017/Service"`.

To overwrite the logic we can add the namespace manually:
```Elixir
config :castile, overwrite_namespace: "http://lsretail.com/LSOmniService/EComm/2017/Service"
```


**Envelope**

To have an `ser:` prefix yo ne

Looks like:
```xml
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
        <soapenv:Header/>
        <soapenv:Body>
            <ser:Login xmlns:ser="http://lsretail.com/LSOmniService/EComm/2017/Service">
              <ser:userName>tom</ser:userName>
              <ser:password>tom.1</ser:password>
              <ser:deviceId></ser:deviceId>
            </ser:Login>
        </soapenv:Body>
      </soapenv:Envelope>
```

# TODO

- [X] Faults (1.1)
- [ ] HTTP client as adapter (specify module)
- [ ] SOAP 1.2 support
- [ ] RPC/encoding RPC/literal style (multiple bodies)
- [ ] WSDL 2.0 support
- [ ] Attachments/multipart

# Thanks

- [detergent](https://github.com/devinus/detergent)/yaws for the original SOAP
    implementation.
- [bet365/soap](https://github.com/bet365/soap) for some of the ideas/fixes
    (simplifying the WSDL XSDs, already_imported schema patch)
