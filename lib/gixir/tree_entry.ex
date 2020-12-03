defmodule Gixir.TreeEntry do
  defstruct repo: nil, oid: nil, filemode: nil, type: nil, name: nil

  alias Gixir.{Repository, Oid, Nif, Error}

  @type tree_entry_type :: :blob | :tree
  @type t :: %__MODULE__{
          repo: Repository.t(),
          oid: Oid.t(),
          filemode: integer,
          type: tree_entry_type,
          name: String.t()
        }

  @spec to_struct(Repository.t(), Oid.t(), {String.t(), String.t(), integer, tree_entry_type}) ::
          t
  def to_struct(repo, oid, {name, _, filemode, type}) do
    %__MODULE__{repo: repo, oid: oid, name: name, filemode: filemode, type: type}
  end
end
