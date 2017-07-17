defmodule Gixir.Tree do
  defstruct gixir_pid: nil, oid: nil

  alias Gixir.Tree

  def to_struct(gixir_pid, oid) do
    %Tree{gixir_pid: gixir_pid, oid: oid}
  end
end
