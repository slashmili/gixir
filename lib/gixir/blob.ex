defmodule Gixir.Blob do
  defstruct gixir_pid: nil

  def from_workdir(repo, file_path) do
    GenServer.call(repo, {:blob_from_workdir, {file_path}})
  end
end
