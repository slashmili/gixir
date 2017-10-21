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
    with {:ok, list_tree_entry} <- Gixir.Nif.tree_lookup(repo, oid) do
      tree_ok_return(oid, repo, list_tree_entry)
    end
  end

  def lookup_bypath(repo, %Tree{} = tree, path) do
    case Gixir.Nif.tree_lookup_bypath(repo, tree.oid, path) do
      {:ok, oid, list_tree_entry} when is_list(list_tree_entry) -> tree_ok_return(oid, repo, list_tree_entry)
      {:ok, tree_entry} when is_tuple(tree_entry) -> {:ok, TreeEntry.to_struct(repo, tree_entry)}
      oth -> oth
    end
  end

  defp tree_ok_return(oid, repo, response) do
    tree = %Tree{
      oid: oid,
      gixir_pid: repo,
      entries: Enum.map(response, fn e -> TreeEntry.to_struct(repo, e) end)
    }
    {:ok, tree}
  end
end
