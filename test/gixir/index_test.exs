defmodule Gixir.IndexTest do
  use ExUnit.Case
  import Gixir.TestHelper

  alias Gixir.{Repository, Index}

  test "write a file to index" do
    {:ok, repo} = repo_fixture()
    {:ok, repo_path} = Repository.workdir(repo)

    {:ok, %Index{} = index} = Index.new(repo)

    File.write!(Path.join(repo_path, "README.md"), "hi\n")

    :ok = Index.add(index, "README.md")
    {:ok, commit_tree} = Index.write_tree(index)
    assert byte_size(commit_tree) == 40
    assert :ok == Index.write(index)
  end
end
