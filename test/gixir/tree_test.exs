defmodule Gixir.TreeTest do
  use ExUnit.Case
  doctest Gixir
  import Gixir.TestHelper

  alias Gixir.{Repository, Branch, Tree, TreeEntry}

  test "load tree" do
    {:ok, repo} = repo_fixture()
    {:ok, repo_path} = Repository.workdir(repo)
    System.cmd("touch", ["README.md"], [cd: repo_path])
    System.cmd("git", ["add", "README.md"], [cd: repo_path])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_path])
    {:ok, branch} = Gixir.Repository.lookup_branch(repo, "master", :local)
    {:ok, commit} = Branch.head(branch)
    {:ok, tree} = Tree.lookup(repo, commit.tree.oid)
    assert %Tree{} = tree
    assert length(tree.entries) == 1
    entry = %TreeEntry{} = List.first(tree.entries)
    assert entry.name == "README.md"
    assert entry.type == :blob
  end
end
