defmodule Gixir.Commit do
  defstruct repo: nil

  alias Gixir.{Repository, Oid, Signature, Nif, Error, Tree}

  @type t :: %Oid{reference: reference, repo: Repository.t(), type: :commit}

  @doc """
  Creates a commit

    If the `update_ref` is not `nil`, name of the reference that will be
    updated to point to this commit. If the reference is not direct, it will
    be resolved to a direct reference. Use "HEAD" to update the HEAD of the
    current branch and make it point to this commit. If the reference
    doesn't exist yet, it will be created. If it does exist, the first
    parent must be the tip of this branch.
  """
  @spec create(
          Repository.t(),
          Signature.t(),
          Signature.t(),
          String.t(),
          Oid.t(),
          list(any),
          String.t() | nil
        ) :: {:ok, Oid.t()} | {:error, Error.t()} | no_return
  def create(
        repo,
        author,
        committer,
        message,
        %Oid{type: :tree} = tree,
        parents,
        update_ref \\ nil
      ) do
    author = Signature.to_map(author)
    committer = Signature.to_map(committer)

    result =
      Nif.commit_create(
        repo.reference,
        author,
        committer,
        message,
        tree.reference,
        Enum.map(parents, & &1.reference),
        update_ref
      )

    case result do
      {:ok, ref} -> {:ok, %Oid{reference: ref, type: :commit, repo: repo}}
      error -> Error.to_error(error, __MODULE__)
    end
  end

  @spec get_tree(t) :: {:ok, Tree.t()} | {:error, Error.t()} | no_return
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
