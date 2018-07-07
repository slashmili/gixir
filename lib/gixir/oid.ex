defmodule Gixir.Oid do
  defstruct reference: nil, type: nil

  @type index_type :: :commit | :tree | :blob | :tag
  @type t :: %{reference: reference, type: index_type}
end
