defmodule Gixir.Branch.Test do
  use ExUnit.Case
  alias Gixir.{Branch, Commit, Repository}
  import Gixir.TestHelper

  test "get list of branches" do
    {:ok, repo} = repo_fixture()
    {:ok, repo_path} = Repository.workdir(repo)
    System.cmd("touch", ["README.md"], [cd: repo_path])
    System.cmd("git", ["add", "README.md"], [cd: repo_path])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_path])
    assert {:ok, branches } = Gixir.Repository.branches(repo)
    assert length(branches) == 1
    assert List.first(branches).name == "master"
  end

  test "get specific branch" do
    {:ok, repo} = repo_fixture()
    {:ok, repo_path} = Repository.workdir(repo)
    System.cmd("touch", ["README.md"], [cd: repo_path])
    System.cmd("git", ["add", "README.md"], [cd: repo_path])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_path])
    assert {:ok, branch} = Gixir.Repository.lookup_branch(repo, "master", :local)
    assert branch.name == "master"
    assert branch.type == :local
  end

  test "try to get invalid branch" do
    {:ok, repo} = repo_fixture()
    assert {:error, {:lookup_branch, "Cannot locate local branch 'master'"}} = Gixir.Repository.lookup_branch(repo, "master", :local)
  end

  test "get target of a branch" do
    {:ok, repo} = repo_fixture()
    {:ok, repo_path} = Repository.workdir(repo)
    System.cmd("touch", ["README.md"], [cd: repo_path])
    System.cmd("git", ["add", "README.md"], [cd: repo_path])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_path])
    assert {:ok, branch} = Gixir.Repository.lookup_branch(repo, "master", :local)
    commit = Branch.target(branch)
    assert %Commit{} = commit
    assert commit.message == "init\n"
    assert byte_size(commit.tree.oid) == 40
  end
end
