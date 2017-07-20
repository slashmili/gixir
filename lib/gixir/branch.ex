defmodule Gixir.Branch do
  defstruct gixir_pid: nil, name: nil, type: nil

  alias Gixir.{Branch, Commit, Commit.Author, Tree}

  def build_struct(gixir_pid, {name, type}) do
    %Branch{gixir_pid: gixir_pid, name: name, type: type}
  end

  @doc """
  return the `Gixir.Commit` that associated to head given branch
  """
  def head(branch) do
    with {:ok, response} <- GenServer.call(branch.gixir_pid, {:branch_head, {branch.name}}) do
      {oid, _parents, tree_oid, {message, _message_encoding}, author_signature, committer_signature} = response
      author = Author.to_struct(author_signature)
      committer = Author.to_struct(committer_signature)
      tree = Tree.to_struct(branch.gixir_pid, tree_oid)
      {:ok, Commit.to_struct(oid, message, tree, author, committer)}
    end
  end
end
