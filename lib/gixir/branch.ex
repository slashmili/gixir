defmodule Gixir.Branch do
  defstruct path: nil, gixir_pid: nil, name: nil, type: nil

  alias Gixir.Branch

  def build_struct(gixir_pid, path, {name, type}) do
    %Branch{gixir_pid: gixir_pid, path: path, name: name, type: type}
  end
end
