defmodule Gixir.Commit do
  defstruct repo: nil

  alias Gixir.{Repository, Oid, Signature, Nif, Error, Tree}

  @type t :: %Oid{type: :commit}

  @spec create(
          Repository.t(),
          Signature.t(),
          Signature.t(),
          String.t(),
          Oid.t(),
          list(any),
          String.t() | nil
        ) :: {:ok, Oid.t()} | {:error, Error.t()} | no_return
  def create(repo, author, committer, message, %Oid{type: :tree} = tree, parents, update_ref) do
    author = Signature.to_map(author)
    committer = Signature.to_map(committer)

    result =
      Nif.commit_create(
        repo.reference,
        author,
        committer,
        message,
        tree.reference,
        parents,
        update_ref
      )

    case result do
      {:ok, ref} -> {:ok, %Oid{reference: ref, type: :commit, repo: repo}}
      error -> Error.to_error(error, __MODULE__)
    end
  end

  @spec get_tree(t) :: {:ok, any}
  def get_tree(%Oid{type: :commit} = commit_oid) do
    case Nif.commit_tree(commit_oid.repo.reference, commit_oid.reference) do
      {:ok, tree_id} ->
        oid = Oid.to_struct(tree_id, :tree, commit_oid.repo)
        {:ok, Tree.to_struct(commit_oid.repo, oid)}

      error ->
        Error.to_error(error, __MODULE__)
    end
  end
end
