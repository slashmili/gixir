defmodule Gixir.IndexTest do
  use ExUnit.Case
  import Gixir.TestHelper

  alias Gixir.{Repository, Index, Oid}

  test "write a file to index" do
    {:ok, repo} = repo_fixture()
    repo_path = Repository.workdir(repo)

    assert {:ok, %Index{} = index} = Repository.index(repo)

    File.write!(Path.join(repo_path, "README.md"), "hi\n")

    assert :ok = Index.add(index, "README.md")
    assert {:ok, oid} = Index.write_tree(index)
    assert %Oid{} = oid
  end
end
