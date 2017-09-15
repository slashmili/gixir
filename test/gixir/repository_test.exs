defmodule Gixir.RepositoryTest do
  use ExUnit.Case

  defp get_random_repo_path do
  name = :crypto.strong_rand_bytes(9) |> Base.encode16(case: :lower)
  Path.expand("./priv/test_tmp/#{name}")
  end

  test "init a repo" do
    repo_path = get_random_repo_path()
    {:ok, _repo} = Gixir.Repository.init_at(repo_path)
    refute File.exists? Path.join(repo_path, "HEAD")
  end

  test "init bare repo" do
    repo_path = get_random_repo_path()
    {:ok, _repo} = Gixir.Repository.init_at(repo_path, bare: true)
    assert File.exists? Path.join(repo_path, "HEAD")
  end

  test "fail on wrong repo path" do
    repo_path = "/tmp1111/asd"
    {:error, -1} = Gixir.Repository.init_at(repo_path, bare: true)
  end

  test "open an existing repository" do
    repo_path = get_random_repo_path()
    {:ok, _repo} = Gixir.Repository.init_at(repo_path, bare: true)
    {:ok, _repo} = Gixir.Repository.open(repo_path)
  end
end
