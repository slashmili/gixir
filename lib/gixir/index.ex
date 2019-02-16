defmodule Gixir.Index do
  defstruct [:repo, :file_paths]
  alias Gixir.FileStorage

  def new(repo) do
    %__MODULE__{repo: repo}
  end

  def add_path(%__MODULE__{} = index, file_path) do
    case FileStorage.write(index.repo, :blob, file_name: file_path) do
      {:ok, _} -> {:ok, %{index | file_paths: [file_path | index.file_paths]}}
    end
  end

  def write_tree(%__MODULE__{} = index) do
    # should create tree, if a file is in directroy
    # should create a new tree for the place that directroy exisits
    # and then create object for the file
    throw(:to_store_a_tree_from_file_paths)
  end

  def write(%__MODULE__{} = index) do
    throw(:to_save_into_git_index_file)
  end
end
