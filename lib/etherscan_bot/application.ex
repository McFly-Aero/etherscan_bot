defmodule EtherscanBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # List all child processes to be supervised
    children = [
      worker(EtherscanBot.Watcher, [])
      # Starts a worker by calling: EtherscanBot.Worker.start_link(arg)
      # {EtherscanBot.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EtherscanBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
