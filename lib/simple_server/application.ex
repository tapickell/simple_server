defmodule SimpleServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: SimpleServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> SimpleServer.WebServer.accept(port) end},
        restart: :permanent
      ),
      FileService.Store.child_spec(name: :docs)
    ]

    opts = [strategy: :one_for_one, name: SimpleServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
