defmodule SimpleServer.Endpoint do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(_) do
    {:ok, []}
  end
end
