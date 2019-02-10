defmodule Gixir.Storage do
  def to_object(:blob, content) do
    "blob #{byte_size(content)}" <> <<0>> <> content
  end

  def sha(raw_object) do
    Base.encode16(:crypto.hash(:sha, raw_object), case: :lower)
  end

  def from_object(raw_object) do
    case inflate(raw_object) do
      <<"tree"::binary, " ", rest::binary>> ->
        {content, size} = find_size_and_content(rest)
        {:ok, %{oid: nil, entries: from_object_entries(content, size)}}

      <<"blob"::binary, " ", rest::binary>> ->
        {content, _size} = find_size_and_content(rest)
        {:ok, %{oid: nil, type: :blob, content: content}}
    end
  end

  def deflate(raw_content) do
    zlib = :zlib.open()
    :zlib.deflateInit(zlib)

    zlib
    |> :zlib.deflate(raw_content, :finish)
    |> List.first()
  end

  def inflate(raw_object) do
    zlib = :zlib.open()
    :zlib.inflateInit(zlib)

    zlib
    |> :zlib.inflate(raw_object)
    |> List.first()
  end

  defp from_object_entries(content, size) do
    split_records(content, [])
  end

  defp split_records(<<>>, acc), do: acc

  defp split_records(content, acc) do
    length_until_0 = content_size_length(content, 0)
    <<header::binary-size(length_until_0), 0, oid::binary-size(20), rest::binary>> = content
    acc = acc ++ [parse_tree_line(header, oid)]
    split_records(rest, acc)
  end

  defp parse_tree_line(<<"100644"::binary, " ", name::binary>>, oid) do
    %{name: name, oid: Base.encode16(oid, case: :lower), type: :blob, mode: 100_644}
  end

  defp parse_tree_line(<<"40000"::binary, " ", name::binary>>, oid) do
    %{name: name, oid: Base.encode16(oid, case: :lower), type: :tree, mode: 40000}
  end

  def find_size_and_content(data) do
    length_of_size_string = content_size_length(data, 0)

    case data do
      <<length::binary-size(length_of_size_string), 0, content::binary>> ->
        {size, _} = Integer.parse(length)
        {content, size}
    end
  end

  defp content_size_length(<<0, reset::binary>>, acc) do
    acc
  end

  defp content_size_length(<<current, reset::binary>> = full, acc) do
    content_size_length(reset, acc + 1)
  end
end
