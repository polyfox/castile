# Castile

Castile is an Elixir incarnation of [Detergent](https://github.com/devinus/detergent), the SOAP API client.

We really wanted to use it but ran into some issues and also wanted to use
HTTPoison as the HTTP client.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `castile` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:castile, "~> 0.1.0"}
  ]
end
```

Docs can be found at [https://hexdocs.pm/castile](https://hexdocs.pm/castile).

## Usage

```elixir
# It's recommended to do init_model at compile time, as an @attr
@model = Castile.init_model("CountryInfoService.wsdl")

{:ok, resp} = Castile.call(@model, :CountryISOCode, %{sCountryName: "Netherlands"})
```

# TODO

- [ ] HTTP client as adapter (specify module)
- [ ] SOAP 1.2 support
- [ ] RPC/encoding RPC/literal style (multiple bodies)
- [ ] WSDL 2.0 support
- [ ] Attachments/multipart
- [ ] Faults
