defmodule Proj1.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Proj1.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Proj1Web.Endpoint, []),
      # Starts a worker by calling: Proj1.Worker.start_link(arg)
      # {Proj1.Worker, arg},
      worker(MyRegistry, [[name1: :engine1]]),
      worker(Server, [[name: :server]])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proj1.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Proj1Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
