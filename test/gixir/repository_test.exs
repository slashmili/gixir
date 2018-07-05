defmodule Gixir.RepositoryTest do
  use ExUnit.Case

  defp get_random_repo_path do
    name = :crypto.strong_rand_bytes(9) |> Base.encode16(case: :lower)
    Path.expand("./priv/test_tmp/#{name}")
  end

  test "init a repo" do
    repo_path = get_random_repo_path()
    assert {:ok, repo} = Gixir.Repository.init_at(repo_path, bare: false)
    assert repo.path == repo_path
    assert is_reference(repo.reference)
    refute File.exists?(Path.join(repo_path, "HEAD"))
  end
end
