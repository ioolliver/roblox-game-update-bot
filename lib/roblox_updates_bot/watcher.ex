defmodule RobloxUpdatesBot.Watcher do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    first_check()
    {:ok, %{}}
  end

  def first_check() do
    GenServer.cast(__MODULE__, {:check, true})
  end

  def schedule_check() do
    :timer.sleep(5000)
    GenServer.cast(__MODULE__, {:check, false})
  end

  def game_updated(universe_id) do
    IO.puts("#{universe_id} ATUALIZOU!")
  end

  def check_for_updates() do
    last_info = RobloxUpdatesBot.Worker.get_updates_date()
    RobloxUpdatesBot.Worker.get_updated_games_date()
    |> IO.inspect()
    |> Enum.each(fn {u_id, date} ->
      if date != last_info["#{u_id}"] do
        RobloxUpdatesBot.Worker.update_game_date(u_id, date)
        game_updated(u_id)
      end
    end)
  end

  @impl true
  def handle_cast({:check, true}, state) do
    schedule_check()
    {:noreply, state}
  end
  def handle_cast({:check, false}, state) do
    Logger.log(:info, "[ROBLOX BOT WATCHER] Checking for updates...")
    check_for_updates()
    schedule_check()
    {:noreply, state}
  end
  def handle_cast(_, state), do: {:noreply, state}

end
