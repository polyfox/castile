defmodule Castile do
  @moduledoc """
  Documentation for Castile.
  """

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

  @doc """
  Converts an operation's parameters into XML.

  ## Examples

      iex> Castile.call(model, :CountryISOCode, %{sCountryName: "Netherlands"})
      {:ok, "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><CountryISOCode xmlns=\"http://www.oorsprong.org/websamples.countryinfo\"><sCountryName>Netherlands</sCountryName></CountryISOCode></soap:Body></soap:Envelope>"}
  """
  defdelegate create_envelope(model, operation, params \\ %{}), to: Castile.Envelope, as: :create

  @doc """
  Parses an xml body response to a map like structure.

  ## Examples
    iex> Castile.call(model, :CountryISOCode, "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\r\n  <soap:Body>\r\n    <m:CountryISOCodeResponse xmlns:m=\"http://www.oorsprong.org/websamples.countryinfo\">\r\n      <m:CountryISOCodeResult>NL</m:CountryISOCodeResult>\r\n    </m:CountryISOCodeResponse>\r\n  </soap:Body>\r\n</soap:Envelope>")
    {:ok, "NL"}
  """
  defdelegate parse_response(model, operation, body), to: Castile.Response, as: :parse
end
