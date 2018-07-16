defmodule Gixir.Tree do
  defstruct repo: nil, oid: nil

  alias Gixir.{Repository, Oid, Nif, Error, TreeEntry}

  @type t :: %__MODULE__{repo: Repository.t(), oid: Oid.t()}

  @spec to_struct(Repository.t(), Oid.t()) :: t
  def to_struct(repo, oid) do
    %__MODULE__{repo: repo, oid: oid}
  end

  @spec get(t) :: {:ok, list(TreeEntry.t())} | {:error, Error.t()} | no_return
  def get(%__MODULE__{} = tree) do
    with {:ok, tree_entries} <- Nif.tree_get_by_oid(tree.repo.reference, tree.oid.reference) do
      tree_entries
      |> Enum.map(&TreeEntry.to_struct(tree.repo, tree.oid, &1))
      |> okey
    else
      error -> Error.to_error(error, __MODULE__)
    end
  end

  defp okey(r), do: {:ok, r}
end
