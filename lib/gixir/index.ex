defmodule Gixir.Index do
  defstruct gixir_repo_ref: nil, index_ref: nil

  alias Gixir.Index

  def new(repo) do
    with {:ok, id} <- Gixir.Nif.index_new(repo) do
      {:ok, %Index{gixir_repo_ref: repo, index_ref: id}}
    end
  end

  @doc """
  Add or update an index entry from a file on disk.

  The `file_path` must be relative to the repository's working folder and must be readable.

  This method will fail in bare index instances.

  for more detail read documents for `git_index_add_bypath`
  """
  def add(index, file_path) do
    Gixir.Nif.index_add_bypath(index.index_ref, file_path)
  end

  @doc """
  This method will scan the index and write a representation of its current state back to disk;
  it recursively creates tree objects for each of the subtrees stored in the index, but only returns the OID of the root tree.
  This is the OID that can be used e.g. to create a commit.
  """
  def write_tree(index) do
    Gixir.Nif.index_write_tree(index.index_ref)
  end

  @doc """
  Write an existing index object from memory back to disk using an atomic file lock.
  """
  def write(index) do
    Gixir.Nif.index_write(index.index_ref)
  end
end
