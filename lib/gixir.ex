defmodule Gixir do
  @moduledoc """
  Documentation for Gixir.
  """
  use GenServer

  defstruct [ port: nil]


  def start(opts \\ []) do
    GenServer.start(__MODULE__, opts)
  end

  def ping(pid) do
    GenServer.call(pid, :ping)
  end

  def init(_) do
    executable = :code.priv_dir(:gixir) ++ '/gixir'
    port_opts = [{:args, []}, {:packet, 2}, :nouse_stdio, :binary, :exit_status]
    port = Port.open({:spawn_executable, executable}, port_opts)
    state = %Gixir{port: port}
    {:ok, state}
  end

  def handle_call(:ping, _from, state) do
    response = call_port(state, :ping, {})
    {:reply, response, state}
  end

  def handle_call({:repository_init_at, path, bare}, _from, state) do
    response = call_port(state, :repository_init_at, {path, bare})
    {:reply, response, state}
  end

  def handle_call({:repository_open, path}, _from, state) do
    response = call_port(state, :repository_open, {path})
    {:reply, response, state}
  end

  defp call_port(state, command, arguments, timeout \\ 40000) do
    msg = {command, arguments}
    send(state.port, {self(), {:command, :erlang.term_to_binary(msg)}})
    receive do
      {_, {:data, <<?r,response::binary>>}} ->
        :erlang.binary_to_term(response)
    after
      timeout ->
        # Not sure how this can be recovered
        exit(:port_timed_out)
    end
  end
end
