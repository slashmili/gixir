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
  def repo_lookup_branch(_repo_ref, _name, _type), do: exit(:nif_not_loaded)
  def repo_head(_repo), do: exit(:nif_not_loaded)
  def index_new(_repo_ref), do: exit(:nif_not_loaded)
  def index_add_bypath(_index_ref, _path), do: exit(:nif_not_loaded)
  def index_write_tree(_index_ref), do: exit(:nif_not_loaded)
  def index_write(_index_ref), do: exit(:nif_not_loaded)
  def commit_create(_repo_ref, _args), do: exit(:nif_not_loaded)
  def commit_lookup(_repo_ref, _oid), do: exit(:nif_not_loaded)
  def commit_get_message(_repo_ref, _oid), do: exit(:nif_not_loaded)
  def commit_get_tree_oid(_repo_ref, _oid), do: exit(:nif_not_loaded)
  def tree_lookup(_repo_ref, _oid), do: exit(:nif_not_loaded)
  def tree_lookup_bypath(_repo_ref, _oid, _path), do: exit(:nif_not_loaded)
end
