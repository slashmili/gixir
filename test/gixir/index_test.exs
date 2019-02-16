defmodule Gixir.IndexTest do
  use ExUnit.Case
  use PropCheck
  import Gixir.TestHelper

  alias Gixir.{Repository, Index, Storage}

  describe "add_path/2" do
    property "write a blob object for a file" do
      forall data <- [content: utf8()] do
        {:ok, repo} = repo_fixture()
        repo_path = Repository.workdir(repo)

        assert %Index{} = index = Index.new(repo)

        file_content = data[:content]
        File.write!(Path.join(repo_path, "README.md"), file_content)

        assert {:ok, index} = Index.add_path(index, "README.md")
        sha = Storage.sha(Storage.to_object(:blob, file_content))

        stored_git_data = System.cmd("git", ["cat-file", "-p", sha], cd: repo_path)
        assert elem(stored_git_data, 1) == 0
        assert elem(stored_git_data, 0) == file_content
      end
    end
  end

  describe "write_tree/1" do
    test "write a tree object" do
      {:ok, repo} = repo_fixture()
      repo_path = Repository.workdir(repo)

      assert %Index{} = index = Index.new(repo)

      file_content = "hi\n"
      File.write!(Path.join(repo_path, "README.md"), file_content)

      assert {:ok, index} = Index.add_path(index, "README.md")
      assert {:ok, commit_tree} = Index.write_tree(index)
      assert byte_size(commit_tree) == 40
      assert commit_tree == "45b983be36b73c0788dc9cbcb76cbb80fc7bb057"

      assert {file_content, 0} ==
               System.cmd("git", ["cat-file", "-p", commit_tree], cd: repo_path)
    end
  end

  describe "write/1" do
    @tag :skip
    test "write to index file" do
      {:ok, repo} = repo_fixture()
      index = Repository.index(repo)
      file_content = "hi\n"
      File.write!(Path.join(Repository.workdir(repo), "README.md"), file_content)

      index = Index.add_path(index, "README.md")

      assert :ok == Index.write(index)
    end
  end
end
