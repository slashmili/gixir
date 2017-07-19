defmodule Gixir.TreeEntry do
  defstruct gixir_pid: nil, oid: nil, filemode: nil, type: nil, name: nil

  alias Gixir.TreeEntry

  def to_struct(gixir_pid, {name, oid, filemode, type}) do
    %TreeEntry{gixir_pid: gixir_pid, oid: oid, filemode: filemode, type: type, name: name}
  end
end
