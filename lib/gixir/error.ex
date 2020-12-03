defmodule Gixir.Error do
  defstruct message: nil, id: nil, module: nil

  @type t :: %__MODULE__{id: integer, message: String.t(), module: atom}

  @spec to_error(tuple, atom) :: {:error, t}
  def to_error(error_tuple, module) do
    case error_tuple do
      {:error, {id, message}} -> {:error, new(id, message, module)}
      {:error, error} -> {:error, new(-100, error, module)}
      e -> {:error, new(-101, e, module)}
    end
  end

  @spec new(integer, String.t(), atom) :: t
  def new(id, message, module) do
    %__MODULE__{id: id, message: message, module: module}
  end
end
