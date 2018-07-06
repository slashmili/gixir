defmodule Gixir.Index do
  defstruct reference: nil

  @type t :: %{reference: reference}

  @doc """
  Add or update an index entry from a file on disk.

  The `file_path` must be relative to the repository's working folder and must be readable.

  This method will fail in bare index instances.

  for more detail read documents for `git_index_add_bypath`
  """
  @spec add(t, String.t()) :: :ok | {:error, any} | no_return
  def add(index, file_path) do
    Gixir.Nif.index_add_bypath(index.reference, file_path)
  end
end
