defmodule Gixir.Nif do
  use Rustler, otp_app: :gixir

  @doc """
    iex> Gixir.Nif.add(1, 2)
    {:ok, 3}
  """
  def add(_arg1, _arg2), do: exit(:nif_not_loaded)
  def ping(), do: exit(:nif_not_loaded)
  def repo_init_at(_arg1, _args2), do: exit(:nif_not_loaded)
  def repo_open(_arg2), do: exit(:nif_not_loaded)
  def repo_workdir(_repo_ref), do: exit(:nif_not_loaded)
  def repo_list_branches(_repo_ref), do: exit(:nif_not_loaded)
end
