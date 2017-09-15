defmodule Gixir.Repository do

  alias Gixir.{Branch, Index}

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
    Gixir.Nif.repo_init_at(path, bare)
  end

  def open(path) do
    Gixir.Nif.repo_open(path)
  end

  def branches(repo) do
    with {:ok, branches} <- GenServer.call(repo, {:repository_list_branches, {}}) do
      branches
      |> Enum.map(fn b -> Branch.build_struct(repo, b) end)
      |> (&({:ok, &1})).()
    end
  end

  @doc """
  Lookup a branch by its name in a repository.

  """
  def lookup_branch(repo, name, type) do
    branch_type = if(type == :local, do: 1, else: 2)
    with :ok <- GenServer.call(repo, {:repository_lookup_branch, {name, branch_type}}) do
      {:ok, Branch.build_struct(repo, {name, type})}
    end
  end

  @doc """
  Get the path of the working directory for this repository

    iex>{:ok, repo_path} = Repository.workdir(repo)
  """
  def workdir(repo) do
    GenServer.call(repo, {:repository_workdir, {}})
  end

  def index(repo) do
    %Index{gixir_pid: repo}
  end
end
