defmodule Gixir.RepositoryTest do
  use ExUnit.Case
  import Gixir.TestHelper

  alias Gixir.Repository

  defp get_random_repo_path do
    name = :crypto.strong_rand_bytes(9) |> Base.encode16(case: :lower)
    Path.expand("./priv/test_tmp/#{name}")
  end

  test "initializes a repo" do
    repo_path = get_random_repo_path()
    assert {:ok, repo} = Repository.init_at(repo_path, bare: false)
    assert repo.path == repo_path
    assert is_reference(repo.reference)
    refute File.exists?(Path.join(repo_path, "HEAD"))
  end

  test "fails on wrong repo path" do
    repo_path = "/tmp1111/asd"
    {:error, %{id: -1}} = Repository.init_at(repo_path, bare: true)
  end

  test "opens an existing repo" do
    repo_path = get_random_repo_path()
    assert {:ok, _repo} = Repository.init_at(repo_path, bare: true)
    assert {:ok, _repo} = Repository.open(repo_path)
  end

  test "fails to open an invalid repo directory" do
    repo_path = get_random_repo_path()
    File.mkdir_p(repo_path)
    assert {:error, %{id: -3}} = Repository.open(repo_path)
  end

  test "gets index file for repository" do
    repo_path = get_random_repo_path()
    assert {:ok, _repo} = Repository.init_at(repo_path, bare: true)
  end

  test "gets list of brances" do
    {:ok, repo} = repo_fixture()
    repo_path = Repository.workdir(repo)
    System.cmd("touch", ["README.md"], cd: repo_path)
    System.cmd("git", ["add", "README.md"], cd: repo_path)
    System.cmd("git", ["commit", "-m", "init"], cd: repo_path)

    assert {:ok, branches} = Repository.branches(repo)
    assert List.first(branches).name == "master"
  end
end
