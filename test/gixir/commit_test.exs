defmodule Gixir.CommitTest do
  use ExUnit.Case
  import Gixir.TestHelper

  alias Gixir.{Repository, Index, Commit}


  test "Commit data to repo" do
    {:ok, repo} = repo_fixture()
    {:ok, repo_path} = Repository.workdir(repo)

    {:ok, %Index{} = index} = Index.new(repo)

    File.write!(Path.join(repo_path, "README.md"), "hi\n")

    :ok = Index.add(index, "README.md")
    {:ok, commit_tree} = Index.write_tree(index)
    assert :ok == Index.write(index)

    author = %{email: "foo@bar.com", datetime: DateTime.utc_now, name: "Foo Bar"}
    commit_data = %{author: author, message: "hello", committer: author, parents: [], tree: commit_tree, update_ref: "HEAD"}
    assert {:ok, %Commit{} = commit} = Commit.create(repo, commit_data)
    assert byte_size(commit.oid) == 40
    assert commit.tree.oid == "444a8fa98e219b9ee8585973bba9425676aba452"

    {:ok, %Index{} = index} = Index.new(repo)
    File.write!(Path.join(repo_path, "anotherfile.code"), "hi again\n")
    :ok = Index.add(index, "README.md")
    {:ok, commit_tree} = Index.write_tree(index)
    assert :ok == Index.write(index)
    commit_data = %{author: author, message: "hello", committer: author, parents: [commit.oid], tree: commit_tree, update_ref: "HEAD"}
    assert {:ok, %Commit{} = commit} = Commit.create(repo, commit_data)
    assert byte_size(commit.oid) == 40
    assert commit.tree.oid == "444a8fa98e219b9ee8585973bba9425676aba452"
  end
end
