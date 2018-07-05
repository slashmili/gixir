defmodule Gixir.Repository do
  defstruct path: nil, reference: nil

  @type t :: %__MODULE__{path: String.t(), reference: reference()}

  @doc """
  Initialize a Git repository in `path`. This implies creating all the
  necessary files on the FS, or re-initializing an already existing
  repository if the files have already been created.

  The following options can be passed in the `opts`:

  The `bare` (default set false_  attribute specifies whether
  the Repository should be created on disk as bare or not.
  Bare repositories have no working directory and are created in the root
  of `path`. Non-bare repositories are created in a `.git` folder and
  use `path` as working directory.
  """
  @spec init_at(String.t(), keyword) :: {:ok, t} | {:error, any}
  def init_at(path, opts \\ []) do
    bare = Keyword.get(opts, :bare, false)

    with {:ok, ref} <- Gixir.Nif.repository_init_at(path, bare) do
      {:ok, %__MODULE__{path: path, reference: ref}}
    end
  end
end
