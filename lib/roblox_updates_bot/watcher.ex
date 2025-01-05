defmodule RobloxUpdatesBot.Watcher do
  @moduledoc false

  require Logger
  use GenServer

  alias RobloxUpdatesBot.{Discord, State}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  end
  @impl true
  def init(_) do
    first_check()
    {:ok, %{}}
  end

  defp first_check do
    GenServer.cast(__MODULE__, {:check, true})
  end

  defp schedule_check do
    State.get_fetch_delay()
    |> parse_to_ms()
    |> :timer.sleep()
    GenServer.cast(__MODULE__, {:check, false})
  end

  defp parse_to_ms(seconds), do: seconds * 1000

  def game_updated(universe_id) do
    universe_id
    |> State.fetch_game_info()
    |> Discord.game_updated()
  end

  def check_for_updates do
    last_info = State.get_updates_date()

    State.get_updated_games_date()
    |> Enum.each(fn {u_id, date} ->
      if date != last_info["#{u_id}"] do
        State.update_game_date(u_id, date)
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
