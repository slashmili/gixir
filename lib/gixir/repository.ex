defmodule Gixir.Repository do

  alias Gixir.Repository
  defstruct path: nil, gixir_pid: nil

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
  def init_at(path, opts \\ []) do
    bare = Keyword.get(opts, :bare, false)
    with {:ok, gixir} <- Gixir.start(),
         :ok <- GenServer.call(gixir, {:repository_init_at, {path, bare}}) do
      {:ok, %Repository{path: path, gixir_pid: gixir}}
    else
      error -> error
    end
  end

  def open(path) do
    with {:ok, gixir} <- Gixir.start(),
         :ok <- GenServer.call(gixir, {:repository_open, {path}}) do
      {:ok, %Repository{path: path, gixir_pid: gixir}}
    else
      error -> error
    end
  end

  def list_branches(repo) do
    GenServer.call(repo.gixir_pid, {:repository_list_branches, {repo.path}})
  end
end
