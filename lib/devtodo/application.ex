defmodule Devtodo.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DevtodoWeb.Telemetry,
      Devtodo.Repo,
      {DNSCluster, query: Application.get_env(:devtodo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Devtodo.PubSub},
      DevtodoWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Devtodo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    DevtodoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
