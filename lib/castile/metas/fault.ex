defmodule Castile.Meta.Fault do
  @moduledoc """
  Represents a SOAP (1.1) fault.
  """
  defexception [:detail, :faultactor, :faultcode, :faultstring]

  @type t :: %__MODULE__{
          faultcode: String.t(),
          faultstring: String.t(),
          faultactor: String.t(),
          detail: term
        }

  @spec message(atom | %{:faultstring => any, optional(any) => any}) :: String.t()
  def message(exception) do
    exception.faultstring
  end
end
