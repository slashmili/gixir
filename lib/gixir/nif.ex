defmodule Gixir.Nif do
  @moduledoc """
  Documentation for Gixir.
  """

  use Rustler, otp_app: :gixir, crate: :gixir

  def add(_, _), do: :erlang.nif_error(:nif_not_loaded)
  def repository_init_at(_, _), do: :erlang.nif_error(:nif_not_loaded)
  def repository_open(_), do: :erlang.nif_error(:nif_not_loaded)
  def repository_index(_), do: :erlang.nif_error(:nif_not_loaded)
  def index_add_bypath(_, _), do: :erlang.nif_error(:nif_not_loaded)
  def index_write_tree(_), do: :erlang.nif_error(:nif_not_loaded)
  def index_write(_), do: :erlang.nif_error(:nif_not_loaded)
  def commit_create(_, _, _, _, _, _, _), do: :erlang.nif_error(:nif_not_loaded)
end
