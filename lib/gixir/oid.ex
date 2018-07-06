defmodule Gixir.Oid do
  defstruct reference: nil

  @type t :: %{reference: reference}
end
