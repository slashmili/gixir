defmodule GixirTest do
  use ExUnit.Case
  doctest Gixir

  test "greets the world" do
    assert Gixir.add(1, 2) == {:ok, 3}
  end
end
