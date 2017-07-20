defmodule Gixir.Commit.Author do
  defstruct email: nil, datetime: nil, name: nil

  alias Gixir.Commit.Author
  def to_struct({name, email, timestamp, _offset}) do
    %Author{name: name, email: email, datetime: DateTime.from_unix!(timestamp)}
  end
end
