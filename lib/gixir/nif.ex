defmodule Gixir.Nif do
  @moduledoc """
  Documentation for Gixir.
  """

  use Rustler, otp_app: :gixir, crate: :gixir

  def add(_, _), do: :erlang.nif_error(:nif_not_loaded)
  def repository_init_at(_, _), do: :erlang.nif_error(:nif_not_loaded)
end
