defmodule Gixir.RepositoryTest do
  use ExUnit.Case
  import Gixir.TestHelper
  alias Gixir.Repository

  test "initializes a repo" do
    repo_path = get_random_repo_path()
    assert {:ok, repo} = Repository.init_at(repo_path, bare: false)
    assert repo.path == repo_path
    refute File.exists?(Path.join(repo_path, "HEAD"))
  end

  test "init bare repo" do
    repo_path = get_random_repo_path()
    {:ok, _repo} = Gixir.Repository.init_at(repo_path, bare: true)
    assert File.exists?(Path.join(repo_path, "HEAD"))
  end

  test "fail on wrong repo path" do
    repo_path = "/tmp1111/asd"
    :error = Gixir.Repository.init_at(repo_path, bare: true)
  end

  test "open an existing repository" do
    repo_path = get_random_repo_path()
    {:ok, _repo} = Gixir.Repository.init_at(repo_path, bare: true)
    {:ok, repo} = Gixir.Repository.open(repo_path)
    assert repo.is_bare?
  end
end
