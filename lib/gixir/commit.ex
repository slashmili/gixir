defmodule Gixir.Commit do
  alias Gixir.{Commit, Commit.Author, Tree}
  defstruct message: nil, oid: nil, parents: [], tree: %Tree{},
            author: %Author{}, committer: %Author{}

  def to_struct(oid, message, %Tree{} = tree, %Author{} = author, %Author{} = committer) do
    %Commit{oid: oid, message: message, tree: tree, author: author, committer: committer}
  end
end
