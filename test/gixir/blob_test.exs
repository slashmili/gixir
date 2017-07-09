defmodule Gixir.BlobTest do
  use ExUnit.Case
  doctest Gixir

  alias Gixir.{Repository, Blob}

  defp get_random_repo_path do
    name = :crypto.strong_rand_bytes(9) |> Base.encode16(case: :lower)
    Path.expand("./priv/test_tmp/#{name}")
  end

  test "get oid for not existing file" do
    repo_path = get_random_repo_path()
    {:ok, repo} = Repository.init_at(repo_path)
    assert {:error, {:blob_from_workdir, _}} = Blob.from_workdir(repo, "README.md")
  end

  test "get oid for existing file" do
    repo_path = get_random_repo_path()
    {:ok, repo} = Repository.init_at(repo_path)
    File.write!(Path.join(repo_path, "README.md"), "hi\n")
    assert Blob.from_workdir(repo, "README.md") == {:ok, "45b983be36b73c0788dc9cbcb76cbb80fc7bb057"}
  end
end
