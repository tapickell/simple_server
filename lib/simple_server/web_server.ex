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
    Logger.info("Loop called in WebServer")
    with {:ok, client} <- Tcp.accept(socket) do
      Logger.warn("POST TcpAccept")
      with {:ok, pid} <- Task.Supervisor.start_child(SimpleServer.TaskSupervisor, fn -> serve(client, %Conn{}) end) do
        Logger.warn("POST TaskSupervisor.start_child")
        :ok = Tcp.controlling_process(client, pid)
      else
        error -> Logger.error("ERROR on TaskSupervisor.start_child #{inspect(error)}")
      end
    else
      error -> Logger.error("Accept returned something other than :ok client: #{inspect(error)}")
    end

    loop(socket)
  end

  defp serve(socket, %{complete: true} = conn) do
    Logger.info("serve called with %{complete: true} in conn")
    with {:ok, response} <- RequestHandler.process_request(conn) do
      :ok = Tcp.write_line(socket, response)
      serve(socket, %Conn{})
    end
  end

  defp serve(socket, conn) do
    Logger.info("serve called in WebServer")
    with {:ok, data} <- Tcp.read_line(socket),
      {:ok, new_conn} <- RequestBuilder.parse_line(socket, conn, data) do
      serve(socket, new_conn)
    end
  end

end
