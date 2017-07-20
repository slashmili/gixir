defmodule Gixir.Tree do
  defstruct gixir_pid: nil, oid: nil, entries: []

  Gixir.TreeEntry

  alias Gixir.{Tree, TreeEntry}

  def to_struct(gixir_pid, oid) do
    %Tree{gixir_pid: gixir_pid, oid: oid}
  end

  @doc """
  Lookup a tree object from the repository.
  """
  def lookup(repo, oid) do
    with {:ok, response} <- GenServer.call(repo, {:tree_lookup, {oid}}) do
      tree = %Tree{
        oid: oid,
        gixir_pid: repo,
        entries: Enum.map(response, fn e -> TreeEntry.to_struct(repo, e) end)
      }
      {:ok, tree}
    end
  end

  def lookup_bypath(repo, %Tree{} = tree, path) do
    with {:ok, response} <- GenServer.call(repo, {:tree_lookup_bypath, {tree.oid, path}}) do
      tree = %Tree{
        oid: nil,
        gixir_pid: repo,
        entries: Enum.map(response, fn e -> TreeEntry.to_struct(repo, e) end)
      }
      {:ok, tree}
    end
  end
end
