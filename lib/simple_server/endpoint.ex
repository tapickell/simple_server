defmodule SimpleServer.Endpoint do
  use GenServer

  # TODO this has yet to be implemented and used
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def init(_) do
    {:ok, []}
  end
end
