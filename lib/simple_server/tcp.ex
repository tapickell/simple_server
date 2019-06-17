defmodule SimpleServer.Tcp do

  require Logger

  @opts_listen [:binary, packet: :http, backlog: 120, active: false, reuseaddr: true]
  @opts_http [packet: :http]
  @opts_raw [packet: :raw]

  def listen(port, :http) do
    Logger.info("Tcp.listen")
    :gen_tcp.listen(port, @opts_listen)
  end

  def accept(socket) do
    Logger.info("Tcp.accept")
    with {:ok, client} <- :gen_tcp.accept(socket) do
      {:ok, client}
    else
      {:error, error} ->
        Logger.error(":gen_tcp.accept error #{inspect(error)}")
        {:ok, socket}
    end
  end

  def controlling_process(socket, pid) do
    Logger.info("Tcp.controlling_process")
    :gen_tcp.controlling_process(socket, pid)
  end

  def read_line(socket) do
    Logger.info("Tcp.read_line")
    :gen_tcp.recv(socket, 0)
  end

  def read_raw_data(socket, size) do
    Logger.info("Tcp.read_raw_data")

    :ok = :inet.setopts(socket, @opts_raw)

    with {:ok, sent_data} <- read_data(socket, size) do
      Logger.warn("read_data => #{inspect(sent_data)}")
      :ok = :inet.setopts(socket, @opts_http)
      {:ok, %{data: sent_data}}
    else
      {:error, error} ->
        Logger.error("ERROR: #{inspect(error)}")
        :ok = :inet.setopts(socket, @opts_http)
        {:error, error}
    end
  end

  def write_line(socket, line) do
    Logger.info("Tcp.write_line")
    :gen_tcp.send(socket, line)
  end

  defp read_data(socket, size) do
    Logger.info("Tcp.read_data")
    :gen_tcp.recv(socket, size)
  end

end
