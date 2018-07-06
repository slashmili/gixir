defmodule Gixir.RepositoryTest do
  use ExUnit.Case

  defp get_random_repo_path do
    name = :crypto.strong_rand_bytes(9) |> Base.encode16(case: :lower)
    Path.expand("./priv/test_tmp/#{name}")
  end

  test "initializes a repo" do
    repo_path = get_random_repo_path()
    assert {:ok, repo} = Gixir.Repository.init_at(repo_path, bare: false)
    assert repo.path == repo_path
    assert is_reference(repo.reference)
    refute File.exists?(Path.join(repo_path, "HEAD"))
  end

  test "fails on wrong repo path" do
    repo_path = "/tmp1111/asd"
    {:error, %{id: -1}} = Gixir.Repository.init_at(repo_path, bare: true)
  end

  test "opens an existing repo" do
    repo_path = get_random_repo_path()
    assert {:ok, _repo} = Gixir.Repository.init_at(repo_path, bare: true)
    assert {:ok, _repo} = Gixir.Repository.open(repo_path)
  end

  test "fails to open an invalid repo directory" do
    repo_path = get_random_repo_path()
    File.mkdir_p(repo_path)
    assert {:error, %{id: -3}} = Gixir.Repository.open(repo_path)
  end
end
