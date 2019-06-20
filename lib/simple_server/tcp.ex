defmodule SimpleServer.Tcp do
  @moduledoc """

    ## Notes
    After talking to Seve about his implementation and doing some research about
    non-blocking tcp servers using OTP, it seems like a good idea to separate the
    listener and the acceptor out. There was a note from Ben about the
    passing of control using controlling_process that will slow down the server a bit
    each time it is called, so I want to look at ways to not do that more than once if I don't
    have to. Really not sure why I had to do that in the first place, I need to dive deeper
    into what that is doing and why.

    ## Current Implementation
    What I have done up until this point is wrap the :gen_tcp calls into their own
    module to isolate them and create a space where the different options I am using for switching from
    :http to :raw to recv the file data in the body. There may be a better way to get this data without
    switching, I just have not seen one yet.

    Currently I use the WebServer module to call Listen on TCP and then loop with TCP accept
    Then the loop starts a task on the task supervisor. This simple task just calls the serve
    function on WebServer. Then I call controlling_process passing the client from TCP accept,
    and the pid from the Task.Supervisor.start_child call.
    The serve function is used to read in each packet and the packets are sent to the request builder
    which builds up a Conn struct from each part of the header that comes in. When all the
    header packets have been received then I set complete to true in the Conn struct.
    When eoh end of header is received if the content length is greater than 0
    I then get the raw body data. This is a little messy still as I am making a call into
    TCP to get that raw body data from the request building line parser functions.
    The line parser / request builder should not know how to ask for more data it should only know how
    to parse the lines that come in.

    ## Non Blocking Implmentation
    For non blocking the listener become a GenServer and then a Supervisor is used for the
    clients (acceptors), that are spun up and will receive actively with handle calls.
  """

  require Logger

  @opts_listen [:binary, packet: :http, backlog: 120, active: false, reuseaddr: true, send_timeout_close: true]
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
