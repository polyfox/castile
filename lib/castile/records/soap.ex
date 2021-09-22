defmodule Castile.Records.SOAP do
  @moduledoc """
  SOAP related records. Used when parsing Erlsom output.
  """
  import Record
  defrecord :soap_operation,   :"soap:tOperation",        [:attrs, :required,  :action,   :style]
  defrecord :soap_address,     :"soap:tAddress",          [:attrs, :required,  :location]
  # elixir uses defrecord to interface with erlang but uses nil instead of the
  # erlang default: undefined...?!
  defrecord :soap_fault,    :"soap:Fault",    [attrs: :undefined, faultcode: :undefined, faultstring: :undefined, faultactor: :undefined, detail: :undefined]
  defrecord :soap_body,     :"soap:Body",     [attrs: :undefined, choice: :undefined]
  defrecord :soap_header,   :"soap:Header",   [attrs: :undefined, choice: :undefined]
  defrecord :soap_envelope, :"soap:Envelope", [attrs: :undefined, header: :undefined, body: :undefined, choice: :undefined]
end
