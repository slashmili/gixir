defmodule Gixir.Branch do
  defstruct name: nil, type: nil, repo: nil

  alias Gixir.Repository

  @type branch_type :: :local | :remote
  @type t :: %__MODULE__{name: String.t(), type: branch_type, repo: Repository.t()}

  @spec to_struct(Repository.t(), {String.t(), branch_type}) :: t
  def to_struct(repo, {name, type}) do
    %__MODULE__{repo: repo, name: name, type: type}
  end
end
