defmodule GixirTest do
  use ExUnit.Case
  doctest Gixir

  test "communication with the nif" do
    assert {:ok, :pong} == Gixir.Nif.ping
  end
end
