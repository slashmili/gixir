defmodule Gixir.Repository do
  defstruct path: nil, reference: nil

  @type t :: %__MODULE__{path: String.t(), reference: reference()}

  alias Gixir.{Error, Nif, Index}

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
  @spec init_at(String.t(), keyword) :: {:ok, t} | {:error, any} | no_return()
  def init_at(path, opts \\ []) do
    bare = Keyword.get(opts, :bare, false)

    with {:ok, ref} <- Nif.repository_init_at(path, bare) do
      {:ok, %__MODULE__{path: path, reference: ref}}
    else
      error -> Error.to_error(error, __MODULE__)
    end
  end

  @doc """
  open a Git repository in `path` an return Repository module
  which has reference to the repository.
  """
  @spec open(String.t()) :: {:ok, t} | {:error, any} | no_return()
  def open(path) do
    with {:ok, ref} <- Nif.repository_open(path) do
      {:ok, %__MODULE__{path: path, reference: ref}}
    else
      error -> Error.to_error(error, __MODULE__)
    end
  end

  @doc """
  Get the Index file for this repository.

  If a custom index has not been set, the default index for the repository will be returned (the one located in .git/index).
  """
  @spec index(t) :: {:ok, Index.t()} | {:error, any} | no_return()
  def index(repo) do
    with {:ok, ref} <- Nif.repository_index(repo.reference) do
      {:ok, %Index{reference: ref}}
    end
  end
end
