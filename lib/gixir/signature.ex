defmodule Gixir.Signature do
  defstruct email: nil, datetime: nil, name: nil
  @type t :: %__MODULE__{email: String.t(), datetime: DateTime.t(), name: String.t()}

  @spec to_map(t) :: map
  def to_map(signature) do
    %{
      email: signature.email,
      name: signature.name,
      timestamp: DateTime.to_unix(signature.datetime),
      offset: round(signature.datetime.utc_offset / 60)
    }
  end
end
