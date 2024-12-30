defmodule RobloxUpdatesBot.Worker do
  use GenServer

  alias RobloxUpdatesBot.Roblox

  @roblox_game_url "https://www.roblox.com/games/"

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_game(game_link) do
    case String.starts_with?(game_link, @roblox_game_url) do
      true ->
        universe_id = Roblox.extract_universe_id_from_url(game_link)
        GenServer.call(__MODULE__, {:add, universe_id})
      _ -> {:error, :not_roblox_game}
    end
  end

  def get_updated_games_date() do
    GenServer.call(__MODULE__, :get_updated_games_date)
  end

  def get_updates_date() do
    GenServer.call(__MODULE__, :get_updates_date)
  end

  def update_game_date(universe_id, new_date) do
    GenServer.cast(__MODULE__, {:update_universe_date, universe_id, new_date})
  end

  # Server

  defp insert_new_game(%{universe_ids: universe_ids, last_update_date: last_update_date} = state, universe_id) do
    state
    |> Map.put(:universe_ids, [universe_id | universe_ids])
    |> Map.put(:last_update_date, Map.put(last_update_date, universe_id, Roblox.get_last_update_time(universe_id)))
  end

  @impl true
  def init(_) do
    {:ok, %{ universe_ids: [], last_update_date: %{} }}
  end

  @impl true
  def handle_call({:add, universe_id}, _from, %{universe_ids: universe_ids} = state) do
    case Enum.member?(universe_ids, universe_id) do
      true -> {:reply, {:error, :already_added}, state}
      false -> {:reply, {:ok, universe_id}, insert_new_game(state, universe_id)}
    end
  end
  def handle_call(:get_updated_games_date, _from, %{universe_ids: universe_ids} = state) do
    {:reply, Roblox.get_last_update_time(universe_ids), state}
  end
  def handle_call(:get_updates_date, _from, %{last_update_date: last_update_date} = state) do
    {:reply, last_update_date, state}
  end
  def handle_call(:state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_cast({:update_universe_date, universe_id, new_date}, %{last_update_date: last_update_date} = state) do
    new_last_update_date = Map.put(last_update_date, universe_id, new_date)
    new_state = state
    |> Map.put(:last_update_date, new_last_update_date)
    |> IO.inspect()
    {:noreply, new_state}
  end

end
