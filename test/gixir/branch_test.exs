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
    assert Gixir.Repository.list_branches(repo) == []
  end
end
