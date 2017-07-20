defmodule Gixir.BlobTest do
  use ExUnit.Case
  import Gixir.TestHelper

  alias Gixir.{Repository, Blob}

  test "get oid for not existing file" do
    {:ok, repo} = repo_fixture()

    assert {:error, {:blob_from_workdir, _}} = Blob.from_workdir(repo, "README.md")
  end

  test "get oid for existing file" do
    {:ok, repo} = repo_fixture()
    {:ok, repo_path} = Repository.workdir(repo)
    File.write!(Path.join(repo_path, "README.md"), "hi\n")
    assert Blob.from_workdir(repo, "README.md") == {:ok, "45b983be36b73c0788dc9cbcb76cbb80fc7bb057"}
  end
end
