defmodule Gixir.Blob do
  defstruct path: nil, gixir_pid: nil

  def from_workdir(repo, file_path) do
    GenServer.call(repo.gixir_pid, {:blob_from_workdir, {repo.path, file_path}})
  end
end
