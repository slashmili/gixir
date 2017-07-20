defmodule GixirTest do
  use ExUnit.Case
  doctest Gixir

  test "communication with the git port" do
    {:ok, git} = Gixir.start
    assert {:ok, :pong} == Gixir.ping(git)
  end
end
