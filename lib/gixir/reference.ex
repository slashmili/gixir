defmodule Gixir.Reference do
  defstruct gixir_repo_ref: nil, shorthand: nil, name: nil, target: nil, type: nil

  alias __MODULE__

  def target(%Reference{} = ref) do
    {:ok, ref.target}
  end
end
