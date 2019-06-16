defmodule SimpleServer.WebServer do
  alias SimpleServer.Conn

  require Logger

  @opts [:binary, packet: :http, active: false, reuseaddr: true]
  @opts_raw [:binary, packet: :raw, active: false, reuseaddr: true]

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, @opts)
    Logger.info("Accepting connections on port #{port}")
    loop(socket)
  end

  defp loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, pid} =
      Task.Supervisor.start_child(SimpleServer.TaskSupervisor, fn -> serve(client, %Conn{}) end)

    :ok = :gen_tcp.controlling_process(client, pid)
    loop(socket)
  end

  # conn starts as empty map or struct
  # on completion of request and then response
  # conn should be cleared for the next set of request building
  defp serve(socket, conn) do
    with {:ok, data} <- read_line(socket),
      {:ok, new_conn} <- parse_line(socket, conn, data) do
      serve(socket, new_conn)
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp parse_line(socket, conn, {:http_header, _, :"Content-Length", _, size_str}) do
    Logger.warn("header :: content_length: => #{inspect(conn)}")
    size = List.to_integer(size_str)
    {:ok, %{conn | content_length: size}}
  end

  defp parse_line(socket, conn, {:http_header, _, :"Content-Type", _, type}) do
    Logger.warn("header :: content_type: => #{inspect(conn)}")
    {:ok, %{conn | content_type: type}}
  end

  defp parse_line(socket, conn, {:http_header, _, :"User-Agent", _, agent}) do
    Logger.warn("header :: agent => #{inspect(conn)}")
    {:ok, %{conn | user_agent: agent}}
  end

  defp parse_line(socket, conn, {:http_header, _, :"Host", _, host}) do
    Logger.warn("header :: host => #{inspect(conn)}")
    {:ok, %{conn | host: host}}
  end

  defp parse_line(socket, conn, {:http_header, _, :"Accept", _, accept}) do
    Logger.warn("header :: accept => #{inspect(conn)}")
    {:ok, %{conn | accept: accept}}
  end

  defp parse_line(socket, conn, {:http_request, action, {:abs_path, path}, _}) do
    Logger.warn("header :: http_request => #{inspect(conn)}")
    {:ok, %{conn | path: path, action: action}}
  end

  defp parse_line(socket, %{content_length: nil} = conn, :http_eoh) do
    Logger.warn("end of header => #{inspect(conn)}")
    {:ok, conn}
  end

  defp parse_line(socket, conn, :http_eoh) do
    Logger.warn("end of header => #{inspect(conn)}")
    with {:ok, conn} <- read_raw_data(socket, conn),
         {:ok, response} <- process_request(conn) do
      :ok = send_response(socket, response)
    end
    {:ok, %Conn{}}
  end

  defp parse_line(_, conn, data) do
    Logger.warn("read_line => #{inspect(data)}")
    {:ok, conn}
  end

  defp process_request(conn) do
    Logger.warn("REQUEST:=> #{inspect(conn)}")
    response = build_respponse({200, "OK", "{}"})
    {:ok, response}
  end

  defp read_raw_data(socket, conn) do
    size = conn.content_length
    :ok = :inet.setopts(socket, @opts_raw)

    with {:ok, sent_data} <- read_data(socket, size) do
      Logger.warn("read_data => #{inspect(sent_data)}")
      :ok = :inet.setopts(socket, @opts)
      {:ok, %{conn | body: sent_data}}
    else
      {:error, error} ->
        Logger.error("ERROR: #{inspect(error)}")
        :ok = :inet.setopts(socket, @opts)
        {:ok, conn}
    end
  end

  defp read_data(socket, size) do
    :gen_tcp.recv(socket, size)
  end

  defp build_respponse({code, message, body}) do
    length = byte_size(body) + 1
    """
    HTTP/1.1 #{code} #{message}\r
    Content-Type: application/json\r
    Content-Length: #{length}\r
    Date: #{DateTime.utc_now() |> DateTime.to_iso8601()}\r
    Access-Control-Allow-Origin: *\r
    Access-Control-Allow-Credentials: true\r
    \r\n#{body}
    """ |> IO.inspect(label: "response")
  end

  defp send_response(socket, response) do
    :ok = write_line(socket, response)
  end

  defp write_line(socket, {:ok, line}) do
    :gen_tcp.send(socket, line)
  end

  defp write_line(socket, {:error, :unkown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end

  defp write_line(socket, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, err}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(err)
  end

  defp write_line(socket, line) do
    :gen_tcp.send(socket, line)
  end
end
