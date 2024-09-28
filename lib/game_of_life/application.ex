defmodule GameOfLife.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GameOfLifeWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:game_of_life, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GameOfLife.PubSub},
      # Start a worker by calling: GameOfLife.Worker.start_link(arg)
      # {GameOfLife.Worker, arg},
      # Start to serve requests, typically the last entry
      GameOfLifeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GameOfLife.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GameOfLifeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
