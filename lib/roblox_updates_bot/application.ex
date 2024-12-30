defmodule RobloxUpdatesBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RobloxUpdatesBot.Worker,
      RobloxUpdatesBot.Discord,
      RobloxUpdatesBot.Watcher
      # Starts a worker by calling: RobloxUpdatesBot.Worker.start_link(arg)
      # {RobloxUpdatesBot.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RobloxUpdatesBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
