defmodule Gixir.Repository do

  @doc """
  Creates a repository in the given path
  """
  def init_at(path, bare \\ nil) do
    with {:ok, gixir} <- Gixir.start() do
      GenServer.call(gixir, {:repository_init_at, path, bare == :bare})
    end
  end
end
