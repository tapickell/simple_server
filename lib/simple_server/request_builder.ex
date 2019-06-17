defmodule SimpleServer.RequestBuilder do
  alias SimpleServer.Conn
  alias SimpleServer.Tcp

  require Logger

  def parse_line(socket, conn, {:http_header, _, :"Content-Length", _, size_str}) do
    Logger.warn("header :: content_length: => #{inspect(conn)}")
    size = List.to_integer(size_str)
    {:ok, %{conn | content_length: size}}
  end

  def parse_line(socket, conn, {:http_header, _, :"Content-Type", _, type}) do
    Logger.warn("header :: content_type: => #{inspect(conn)}")
    {:ok, %{conn | content_type: type}}
  end

  def parse_line(socket, conn, {:http_header, _, :"User-Agent", _, agent}) do
    Logger.warn("header :: agent => #{inspect(conn)}")
    {:ok, %{conn | user_agent: agent}}
  end

  def parse_line(socket, conn, {:http_header, _, :"Host", _, host}) do
    Logger.warn("header :: host => #{inspect(conn)}")
    {:ok, %{conn | host: host}}
  end

  def parse_line(socket, conn, {:http_header, _, :"Accept", _, accept}) do
    Logger.warn("header :: accept => #{inspect(conn)}")
    {:ok, %{conn | accept: accept}}
  end

  def parse_line(socket, conn, {:http_request, action, {:abs_path, path}, _}) do
    Logger.warn("header :: http_request => #{inspect(conn)}")
    {:ok, %{conn | path: path, action: action}}
  end

  def parse_line(socket, %{content_length: nil} = conn, :http_eoh) do
    Logger.warn("end of header No Content => #{inspect(conn)}")
    {:ok, %{conn | complete: true}}
  end

  def parse_line(socket, %{content_length: 0} = conn, :http_eoh) do
    Logger.warn("end of header No Content => #{inspect(conn)}")
    {:ok, %{conn | complete: true}}
  end

  def parse_line(socket, conn, :http_eoh) do
    Logger.warn("end of header => #{inspect(conn)}")
    size = conn.content_length
    with {:ok, %{data: data}} <- Tcp.read_raw_data(socket, size) do
      {:ok, %{conn | body: data, complete: true}}
    else
      {:error, error} ->
        {:ok, %{conn | errors: [error | conn.errors]}}
    end
  end

  def parse_line(_, conn, data) do
    Logger.warn("read_line No Match => #{inspect(data)}")
    {:ok, conn}
  end

end
