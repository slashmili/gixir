defmodule Gixir.Repository do
  defstruct [:path, :is_bare?]

  def init_at(path, opts \\ []) do
    is_bare? = Keyword.get(opts, :bare, false)
    do_init(path, is_bare?)
  end

  def open(path) do
    {:ok, %__MODULE__{path: path, is_bare?: File.exists?(Path.join(path, "HEAD"))}}
  end

  def workdir(%__MODULE__{path: path}) do
    path
  end

  def index(%__MODULE__{} = repo) do
    Gixir.Index.new(repo)
  end

  defp do_init(path, is_bare?) do
    args = if is_bare? == true, do: ["--bare", path], else: [path]

    case System.cmd("git", ["init"] ++ args) do
      {_, 0} -> {:ok, %__MODULE__{path: path, is_bare?: is_bare?}}
      _ -> :error
    end
  end
end
