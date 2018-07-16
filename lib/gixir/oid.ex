defmodule Gixir.Oid do
  @moduledoc """
    Unique identity of any object (commit, tree, blob, tag).
  """
  defstruct reference: nil, type: nil, repo: nil
  alias Gixir.Repository

  @type oid_type :: :commit | :tree | :blob | :tag
  @type t :: %__MODULE__{reference: reference, type: oid_type, repo: Repository.t()}

  @spec to_struct(reference, oid_type, Repository.t()) :: t
  def to_struct(reference, type, repo) do
    %__MODULE__{reference: reference, type: type, repo: repo}
  end
end
