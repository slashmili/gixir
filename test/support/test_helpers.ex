defmodule Gixir.TestHelper do
  def repo_fixture do
    repo_path = :crypto.strong_rand_bytes(9) |> Base.encode16(case: :lower)
    repo_path = Path.expand("./priv/test_tmp/#{repo_path}")
    {:ok, repo} = Gixir.Repository.init_at(repo_path)
  end
end
