defmodule Gixir.Commit do
  defstruct repo: nil

  alias Gixir.{Repository, Oid, Signature, Nif, Error}

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
      {:ok, ref} -> {:ok, %Oid{reference: ref, type: :commit}}
      error -> Error.to_error(error, __MODULE__)
    end
  end
end
