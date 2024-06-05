defmodule Cyoa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CyoaWeb.Telemetry,
      Cyoa.Repo,
      {DNSCluster, query: Application.get_env(:cyoa, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Cyoa.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Cyoa.Finch},
      # Start a worker by calling: Cyoa.Worker.start_link(arg)
      # {Cyoa.Worker, arg},
      # Start to serve requests, typically the last entry
      CyoaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cyoa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CyoaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
