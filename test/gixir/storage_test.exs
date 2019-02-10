defmodule Gixir.StorageTest do
  use ExUnit.Case
  import Gixir.TestHelper
  alias Gixir.{Storage, Repository}

  describe "to_object/2" do
    test "from blob" do
      random_text = "what is up, doc?"

      sha = "bd9dbf5aae1a3862dd1526723246b20206e5fc37"
      assert Storage.sha(Storage.to_object(:blob, random_text)) == sha
    end
  end

  describe "from_object/1" do
    test "from tree with a file" do
      {:ok, repo} = repo_fixture()
      repo_path = Repository.workdir(repo)
      System.cmd("mkdir", ["-p", "my-path"], cd: repo_path)
      file_content = "hi\n"
      File.write!(Path.join([repo_path, "my-path", "README.md"]), file_content)
      System.cmd("git", ["add", "my-path/README.md"], cd: repo_path)
      System.cmd("git", ["write-tree"], cd: repo_path)

      tree_object = "#{repo_path}/.git/objects/44/4a8fa98e219b9ee8585973bba9425676aba452"
      assert {:ok, tree} = Storage.from_object(File.read!(tree_object))
      assert entry = List.first(tree.entries)
      assert entry.name == "README.md"
      assert entry.oid == "45b983be36b73c0788dc9cbcb76cbb80fc7bb057"
      assert entry.type == :blob
    end

    test "from tree with one file and one tree" do
      {:ok, repo} = repo_fixture()
      repo_path = Repository.workdir(repo)
      # System.cmd("mkdir", ["-p", "my-path", "inside-path"], cd: repo_path)
      File.mkdir_p!("#{repo_path}/my-path/inside-path")
      File.write!(Path.join([repo_path, "my-path", "file1.md"]), "file1 content")
      File.write!(Path.join([repo_path, "my-path", "inside-path", "file2"]), "file2 content")
      System.cmd("git", ["add", "my-path"], cd: repo_path)
      System.cmd("git", ["write-tree"], cd: repo_path)

      tree_object = "#{repo_path}/.git/objects/98/736d366bfdbc7eb3dac72031e9e3dae9060190"

      assert {:ok, tree} = Storage.from_object(File.read!(tree_object))

      assert length(tree.entries) == 2

      assert file = List.first(tree.entries)
      assert file.type == :blob
      assert file.name == "file1.md"
      assert file.oid == "2e80f50e920610d8e6048341a06bb8cdb2f01df7"
      assert file.type == :blob
      assert file.mode == 100_644

      assert tree = List.last(tree.entries)
      assert tree.type == :tree
      assert tree.name == "inside-path"
      assert tree.oid == "154bb07ba94d4cbc2c94943ba73d62964d98e144"
      assert tree.mode == 40000
    end
  end
end
