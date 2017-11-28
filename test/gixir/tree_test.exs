defmodule Gixir.TreeTest do
  use ExUnit.Case
  doctest Gixir
  import Gixir.TestHelper

  alias Gixir.{Repository, Branch, Tree, TreeEntry, Commit}

  def commit_files(repo) do
    {:ok, repo_path} = Repository.workdir(repo)
    System.cmd("touch", ["README.md"], [cd: repo_path])
    System.cmd("mkdir", ["src"], [cd: repo_path])
    System.cmd("touch", ["src/code.src"], [cd: repo_path])
    System.cmd("git", ["add", "README.md"], [cd: repo_path])
    System.cmd("git", ["add", "src"], [cd: repo_path])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_path])
  end

  test "load tree" do
    {:ok, repo} = repo_fixture()
    commit_files(repo)
    {:ok, branch} = Repository.lookup_branch(repo, "master", :local)
    assert {:ok, commit} = Branch.target(branch)
    assert %Gixir.Tree{} = commit.tree

    {:ok, tree} = Commit.get_tree(commit)
    assert {:ok, tree} = Tree.lookup(repo, tree.oid)
    assert %Tree{} = tree
    assert length(tree.entries) == 2
    [entry_1 , entry_2] = tree.entries
    assert %TreeEntry{} = entry_1
    assert entry_1.name == "README.md"
    assert entry_1.type == :blob
    assert entry_1.filemode == 33188
    assert entry_1.oid == "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391"
    assert %TreeEntry{} = entry_2
    assert entry_2.name == "src"
    assert entry_2.type == :tree
    assert entry_1.filemode == 33188
    assert entry_1.oid == "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391"
  end

  test "Lookup a tree by oid" do
    {:ok, repo} = repo_fixture()
    commit_files(repo)
    {:ok, branch} = Repository.lookup_branch(repo, "master", :local)
    {:ok, commit} = Branch.target(branch)
    assert {:ok, tree} = Commit.get_tree(commit)
    {:ok, %Tree{} = tree} = Tree.lookup(repo, tree.oid)
    assert length(tree.entries) == 2
    [_entry_1 , entry_2] = tree.entries
    {:ok, %Tree{} = tree} = Tree.lookup(repo, entry_2.oid)
    assert length(tree.entries) == 1
    assert tree.oid == entry_2.oid

    #{:error, {:git_tree_lookup, err_msg}} = Tree.lookup(repo, entry_1.oid)
    #assert err_msg =~ "does not match the type"
  end


  test "Look up dir tree by path" do
    {:ok, repo} = repo_fixture()
    commit_files(repo)
    {:ok, branch} = Repository.lookup_branch(repo, "master", :local)
    {:ok, commit} = Branch.target(branch)
    assert {:ok, tree_info} = Commit.get_tree(commit)
    assert {:ok, tree} = Tree.lookup(repo, tree_info.oid)
    [_, entry_2] = tree.entries
    assert entry_2.name == "src"
    assert entry_2.type == :tree
    {:ok, tree} = Tree.lookup_bypath(repo, tree_info, "src")
    [entry_1] = tree.entries
    assert entry_1.name == "code.src"
    assert entry_1.type == :blob
    assert tree.oid == entry_2.oid
  end

  test "Look up file tree by path" do
    {:ok, repo} = repo_fixture()
    commit_files(repo)
    {:ok, branch} = Repository.lookup_branch(repo, "master", :local)
    {:ok, commit} = Branch.target(branch)
    {:ok, tree_info} = Commit.get_tree(commit)
    {:ok, tree} = Tree.lookup(repo, tree_info.oid)
    [_, entry_2] = tree.entries
    assert entry_2.name == "src"
    assert entry_2.type == :tree
    {:ok, %TreeEntry{} = entry} = Tree.lookup_bypath(repo, tree_info, "src/code.src")
    assert entry.name == "code.src"
    assert entry.type == :blob
    assert entry.oid == "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391"
  end

  test "Look up invalid file" do
    {:ok, repo} = repo_fixture()
    commit_files(repo)
    {:ok, branch} = Repository.lookup_branch(repo, "master", :local)
    {:ok, commit} = Branch.target(branch)
    {:ok, tree_info} = Commit.get_tree(commit)
    assert {:error, -3} = Tree.lookup_bypath(repo, tree_info, "src/foo.ex")
  end
end
