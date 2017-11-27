defmodule Gixir.Commit do
  alias Gixir.{Commit, Commit.Author, Tree}
  defstruct gixir_repo_ref: nil, oid: nil , message: nil, oid: nil, parents: [],
            author: nil, committer: nil, tree: nil

  def to_struct(repo, oid) do
    %Commit{gixir_repo_ref: repo, oid: oid}
  end
  def to_struct(repo, commit_oid, message, tree, author, committer) do
    %Commit{
      gixir_repo_ref: repo,
      oid: commit_oid,
      message: message,
      tree: tree,
      author: author,
      committer: committer
    }
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
      message,
      author_arg,
      committer_arg,
      #message_encoding == NULL
      tree,
      parents
    }
    with {:ok, commit_oid, tree_oid} <- Gixir.Nif.commit_create(repo, commit_args) do
      tree = Tree.to_struct(repo, tree_oid)
      {:ok, to_struct(repo, commit_oid, message, tree, Author.to_struct(author_arg), Author.to_struct(committer_arg))}
    end
  end

  def lookup(repo, oid) do
    with :ok <- Gixir.Nif.commit_lookup(repo, oid) do
      {:ok, to_struct(repo, oid)}
    end
  end

  def get_message(%Commit{} = commit) do
    with {:ok, message} <- Gixir.Nif.commit_get_message(commit.gixir_repo_ref, commit.oid) do
      {:ok, %{commit | message: message}}
    end
  end

  def get_tree(%Commit{} = commit) do
    with {:ok, tree_oid} <- Gixir.Nif.commit_get_tree_oid(commit.gixir_repo_ref, commit.oid) do
      {:ok, Tree.to_struct(commit.gixir_repo_ref, tree_oid)}
    end
  end

end
