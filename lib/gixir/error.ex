defmodule Gixir.Error do
  defstruct message: nil, id: nil, module: nil

  @type t :: %__MODULE__{id: integer, message: String.t(), module: atom}

  @spec to_error(tuple, atom) :: t
  def to_error(error_tuple, module) when is_tuple(error_tuple) do
    with {:error, {id, message}} <- error_tuple do
      {:error, new(id, message, module)}
    end
  end

  @spec new(integer, String.t(), atom) :: t
  def new(id, message, module) do
    %__MODULE__{id: id, message: message, module: module}
  end
end
