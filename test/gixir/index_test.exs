defmodule Gixir.IndexTest do
  use ExUnit.Case
  import Gixir.TestHelper

  alias Gixir.{Repository, Index}

  test "write a file to index" do
    {:ok, repo} = repo_fixture()
    repo_path = Repository.workdir(repo)

    assert {:ok, %Index{} = index} = Repository.index(repo)

    File.write!(Path.join(repo_path, "README.md"), "hi\n")

    assert :ok = Index.add(index, "README.md")
    assert {:ok, commit_tree} = Index.write_tree(index)
    assert byte_size(commit_tree) == 40
    assert commit_tree == "444a8fa98e219b9ee8585973bba9425676aba452"
    assert :ok == Index.write(index)
  end
end
