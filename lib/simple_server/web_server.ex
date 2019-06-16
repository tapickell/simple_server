defmodule SimpleServer.WebServer do
  alias SimpleServer.Conn
  alias SimpleServer.RequestBuilder
  alias SimpleServer.RequestHandler
  alias SimpleServer.Tcp

  require Logger

  def accept(port) do
    {:ok, socket} = Tcp.listen(port, :http)
    Logger.info("Accepting connections on port #{port}")
    loop(socket)
  end

  defp loop(socket) do
    {:ok, client} = Tcp.accept(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(SimpleServer.TaskSupervisor, fn -> serve(client, %Conn{}) end)

    :ok = Tcp.controlling_process(client, pid)
    loop(socket)
  end

  defp serve(socket, %{complete: true} = conn) do
    with {:ok, response} <- RequestHandler.process_request(conn) do
      :ok = Tcp.write_line(socket, response)
      serve(socket, %Conn{})
    end
  end

  defp serve(socket, conn) do
    with {:ok, data} <- Tcp.read_line(socket),
      {:ok, new_conn} <- RequestBuilder.parse_line(socket, conn, data) do
      serve(socket, new_conn)
    end
  end

end
