defmodule SimpleServerTest do
  use ExUnit.Case
  # doctest SimpleServer

  @moduletag :capture_log

  setup do
    Application.stop(:simple_server)
    :ok = Application.start(:simple_server)
  end

  setup do
    port = String.to_integer(System.get_env("PORT") || "4040")
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', port, opts)
    %{socket: socket}
  end

  test "create returns ok", %{socket: socket} do
    assert send_and_recv(socket, "CREATE stuff\r\n")
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
