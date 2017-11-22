defmodule Gixir.Branch do
  defstruct gixir_pid: nil, name: nil, type: nil, target_commit: nil

  alias Gixir.{Branch, Commit, Commit.Author, Tree}

  def build_struct(gixir_pid, {name, type, target_commit}) do
    %Branch{gixir_pid: gixir_pid, name: name, type: type, target_commit: target_commit}
  end

  def target(branch) do
    Commit.lookup(branch.gixir_pid, branch.target_commit)
  end
end
