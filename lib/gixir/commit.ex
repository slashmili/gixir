defmodule Gixir.Commit do
  alias Gixir.{Commit, Commit.Author, Tree}
  defstruct gixir_repo_ref: nil, oid: nil , message: nil, oid: nil, parents: [],
            author: nil, committer: nil

  def to_struct(repo, oid) do
    %Commit{gixir_repo_ref: repo, oid: oid}
  end

  def create(repo, commit) do
    #with {:ok, commit_oid, tree_oid} <- GenServer.call(repo, {:commit_create, commit_args}) do
    #  tree = Tree.to_struct(repo, tree_oid)
    #  {:ok, to_struct(commit_oid, message, tree, Author.to_struct(author_arg), Author.to_struct(committer_arg))}
    #end
    :error
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
