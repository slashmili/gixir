defmodule Gixir.TreeTest do
  use ExUnit.Case
  doctest Gixir
  import Gixir.TestHelper

  alias Gixir.{Repository, Branch, Tree, TreeEntry}

  test "load tree" do
    {:ok, repo} = repo_fixture()
    {:ok, repo_path} = Repository.workdir(repo)
    System.cmd("touch", ["README.md"], [cd: repo_path])
    System.cmd("mkdir", ["src"], [cd: repo_path])
    System.cmd("touch", ["src/code.ex"], [cd: repo_path])
    System.cmd("git", ["add", "README.md"], [cd: repo_path])
    System.cmd("git", ["add", "src"], [cd: repo_path])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_path])
    {:ok, branch} = Gixir.Repository.lookup_branch(repo, "master", :local)
    {:ok, commit} = Branch.head(branch)
    {:ok, tree} = Tree.lookup(repo, commit.tree.oid)
    assert %Tree{} = tree
    assert length(tree.entries) == 2
    [entry_1 , entry_2] = tree.entries
    assert %TreeEntry{} = entry_1
    assert entry_1.name == "README.md"
    assert entry_1.type == :blob
    assert %TreeEntry{} = entry_2
    assert entry_2.name == "src"
    assert entry_2.type == :tree
  end
end
