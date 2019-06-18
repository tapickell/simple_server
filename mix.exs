defmodule SimpleServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_server,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {SimpleServer.Application, []}
    ]
  end

  defp deps do
    [
      {:hackney, "~> 1.14.0"},
      {:tesla, "~> 1.2.1"}
    ]
  end
end
