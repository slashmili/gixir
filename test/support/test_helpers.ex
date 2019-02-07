defmodule Gixir.TestHelper do
  def get_random_repo_path do
    name = :crypto.strong_rand_bytes(9) |> Base.encode16(case: :lower)
    Path.expand("./priv/test_tmp/#{name}")
  end
end
