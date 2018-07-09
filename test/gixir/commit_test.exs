defmodule Gixir.CommitTest do
  use ExUnit.Case
  import Gixir.TestHelper

  alias Gixir.{Repository, Index, Commit, Signature, Oid}

  test "commits changes to repo" do
    {:ok, repo} = repo_fixture()
    repo_path = Repository.workdir(repo)

    {:ok, %Index{} = index} = Repository.index(repo)

    File.write!(Path.join(repo_path, "README.md"), "hi\n")

    :ok = Index.add(index, "README.md")
    {:ok, oid} = Index.write_tree(index)
    assert :ok == Index.write(index)

    author = %Signature{email: "foo@bar.com", name: "Foo Bar", datetime: DateTime.utc_now()}

    assert {:ok, %Oid{type: :commit} = commit_oid} =
             Commit.create(repo, author, author, "initial commit", oid, [], "HEAD")

    assert {:ok, tree} = Commit.get_tree(commit_oid)
  end
end
