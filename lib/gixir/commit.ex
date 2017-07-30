defmodule Gixir.Commit do
  alias Gixir.{Commit, Commit.Author, Tree}
  defstruct message: nil, oid: nil, parents: [], tree: %Tree{},
            author: %Author{}, committer: %Author{}

  def to_struct(oid, message, %Tree{} = tree, %Author{} = author, %Author{} = committer) do
    %Commit{oid: oid, message: message, tree: tree, author: author, committer: committer}
  end

  def create(repo, commit) do
    author = commit[:author]
    committer = commit[:committer] || author
    message = commit[:message]
    parents = commit[:parents]
    tree    = commit[:tree]
    update_ref = commit[:update_ref]
    author_arg = {
      author.name,
      author.email,
      DateTime.to_unix(author.datetime),
      round(author.datetime.utc_offset/60)
    }
    committer_arg = {
      committer.name,
      committer.email,
      DateTime.to_unix(committer.datetime),
      round(committer.datetime.utc_offset/60)
    }
    commit_args = {
      update_ref,
      author_arg,
      committer_arg,
      #message_encoding == NULL
      message,
      tree,
      length(parents),
      parents
    }
    with {:ok, commit_oid, tree_oid} <- GenServer.call(repo, {:commit_create, commit_args}) do
      tree = Tree.to_struct(repo, tree_oid)
      {:ok, to_struct(commit_oid, message, tree, Author.to_struct(author_arg), Author.to_struct(committer_arg))}
    end
  end
end
