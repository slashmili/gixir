defmodule GixirTest do
  use ExUnit.Case
  doctest Gixir

  test "greets the world" do
    assert Gixir.hello() == :world
  end
end
