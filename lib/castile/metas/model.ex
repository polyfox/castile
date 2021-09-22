defmodule Castile.Meta.Model do
  @moduledoc """
  Represents the WSDL model, containing the type XSD schema and all
  other WSDL metadata.
  """
  defstruct [:operations, :model]
  @type t :: %__MODULE__{operations: map, model: term}
end
