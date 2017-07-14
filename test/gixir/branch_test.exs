defmodule Gixir.Branch.Test do
  use ExUnit.Case
  doctest Gixir

  defp get_random_repo_path do
  name = :crypto.strong_rand_bytes(9) |> Base.encode16(case: :lower)
  Path.expand("./priv/test_tmp/#{name}")
  end

  test "get list of branches" do
    repo_path = get_random_repo_path()
    {:ok, repo} = Gixir.Repository.init_at(repo_path)
    System.cmd("touch", ["README.md"], [cd: repo_path])
    System.cmd("git", ["add", "README.md"], [cd: repo_path])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_path])
    assert {:ok, branches } = Gixir.Repository.branches(repo)
    assert length(branches) == 1
    assert List.first(branches).name == "master"
  end

  test "get specific branch" do
    repo_path = get_random_repo_path()
    {:ok, repo} = Gixir.Repository.init_at(repo_path)
    System.cmd("touch", ["README.md"], [cd: repo_path])
    System.cmd("git", ["add", "README.md"], [cd: repo_path])
    System.cmd("git", ["commit", "-m", "init"], [cd: repo_path])
    assert {:ok, branch} = Gixir.Repository.lookup_branch(repo, "master", :local)
    assert branch.name == "master"
    assert branch.type == :local
  end

  test "try to get invalid branch" do
    repo_path = get_random_repo_path()
    {:ok, repo} = Gixir.Repository.init_at(repo_path)
    assert {:error, {:lookup_branch, "Cannot locate local branch 'master'"}} = Gixir.Repository.lookup_branch(repo, "master", :local)
  end
end
