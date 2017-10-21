defmodule Gixir.Reference do
  defstruct gixir_repo_ref: nil, shorthand: nil, name: nil, target: nil, type: nil

  alias __MODULE__

  alias Gixir.Commit
  def target(%Reference{type: :branch} = ref) do
    Commit.lookup(ref.gixir_repo_ref, ref.target)
  end
end
