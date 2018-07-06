defmodule Gixir.Index do
  defstruct reference: nil

  @type t :: %{reference: reference}

  alias Gixir.{Error, Nif, Oid}

  @doc """
  Add or update an index entry from a file on disk.

  The `file_path` must be relative to the repository's working folder and must be readable.

  This method will fail in bare index instances.

  for more detail read documents for `git_index_add_bypath`
  """
  @spec add(t, String.t()) :: :ok | {:error, any} | no_return
  def add(index, file_path) do
    Nif.index_add_bypath(index.reference, file_path)
  end

  @doc """
  This method will scan the index and write a representation of its current state back to disk;
  it recursively creates tree objects for each of the subtrees stored in the index, but only returns the OID of the root tree.
  This is the OID that can be used e.g. to create a commit.
  """
  @spec write_tree(t) :: {:ok, any} | {:error, any} | no_return
  def write_tree(index) do
    with {:ok, oid_ref} <- Nif.index_write_tree(index.reference) do
      {:ok, %Oid{reference: oid_ref}}
    else
      error -> Error.to_error(error, __MODULE__)
    end
  end

  @doc """
  Write an existing index object from memory back to disk using an atomic file lock.
  """
  def write(index) do
    Gixir.Nif.index_write(index.reference)
  end
end
