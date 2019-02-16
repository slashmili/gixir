defmodule Gixir.FileStorage do
  alias Gixir.Storage

  def write(repo, :blob, file_name: file_name) do
    content = Storage.to_object(:blob, File.read!(file_full_path(repo, file_name)))
    sha = Storage.sha(content)
    write_object(repo, sha, content)
    {:ok, sha}
  end

  defp write_object(repo, <<two_char::binary-size(2), rest::binary>>, content) do
    path = file_full_path(repo, ".git/objects/#{two_char}")

    File.mkdir_p!(path)
    File.write!("#{path}/#{rest}", Storage.deflate(content))
  end

  defp file_full_path(repo, file_name) do
    "#{repo.path}/#{file_name}"
  end
end
