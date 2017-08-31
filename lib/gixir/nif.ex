defmodule Gixir.Nif do
  use Rustler, otp_app: :gixir

  @doc """
    iex> Gixir.Nif.add(1, 2)
    {:ok, 3}
  """
  def add(_arg1, _arg2), do: exit(:nif_not_loaded)
end
