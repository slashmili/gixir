defmodule Gixir do
  @moduledoc """
  Documentation for Gixir.
  """

  use Rustler, otp_app: :gixir, crate: :gixir

  def add(_num1, _num2), do: exit(:nif_not_loaded)
end
