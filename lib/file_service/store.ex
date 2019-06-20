defmodule FileService.Store do
  use GenServer

  require Logger

  def start_link(opts) do
    table = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, table, name: __MODULE__)
  end

  def insert(key, type, data) do
    GenServer.call(__MODULE__, {:insert, key, type, data})
  end

  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  def init(table) do
    store = :ets.new(table, [:named_table, read_concurrency: true])
    {:ok, %{store: store}}
  end

  # TODO this rcvd an extra tuple of {pid, ref} not sure why
  def handle_call({:insert, key, type, data}, {_pid, _ref}, %{store: store} = state) do
    case :ets.insert(store, {key, type, data}) do
      true ->
        {:reply, :ok, state}
      _ ->
        {:reply, :error, state}
    end
  end

  def handle_call({:lookup, key}, {_pid, _ref}, %{store: store} = state) do
    case :ets.lookup(store, key) do
      [match | _] ->
        {:reply, {:ok, match}, state}
      [] ->
        {:reply, {:error, :no_match}, state}
    end
  end

  def handle_call({:delete, key}, {_pid, _ref}, %{store: store} = state) do
    case :ets.delete(store, key) do
      true ->
        {:reply, :ok, state}
      _ ->
        {:reply, :error, state}
    end
  end

  def handle_call(missed, other, state) do
    Logger.error("HANDLE CALL MISS")
    Logger.error("Missed: #{inspect(missed)}")
    Logger.error("Other: #{inspect(other)}")
    Logger.error("State: #{inspect(state)}")
    {:reply, :ok, state}
  end
end
