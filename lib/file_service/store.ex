defmodule FileService.Store do
  use GenServer

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

  def handle_call({:insert, key, type, data}, %{store: store} = state) do
    case :ets.insert(store, {key, type, data}) do
      true ->
        {:reply, :ok, state}
      _ ->
        {:reply, :error, state}
    end
  end

  def handle_call({:lookup, key}, %{store: store} = state) do
    case :ets.lookup(store, key) do
      [match | _] ->
        {:reply, {:ok, match}, state}
      [] ->
        {:reply, {:error, :no_match}, state}
    end
  end

  def handle_call({:delete, key}, %{store: store} = state) do
    case :ets.delete(store, key) do
      true ->
        {:reply, :ok, state}
      _ ->
        {:reply, :error, state}
    end
  end
end
