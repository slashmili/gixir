defmodule Gixir.Commit.Author do
  defstruct email: nil, datetime: nil, name: nil

  alias Gixir.Commit.Author
  def to_struct({name, email, timestamp, offset}) do
    datetime = %{DateTime.from_unix!(timestamp) | utc_offset: offset * 60, zone_abbr: "", time_zone: ""}
    %Author{name: name, email: email, datetime: DateTime.from_unix!(timestamp)}
  end
end
