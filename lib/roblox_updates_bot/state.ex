defmodule RobloxUpdatesBot.State do
  @moduledoc """
  This module handles the BOT's state.
  """
  use GenServer

  alias RobloxUpdatesBot.Roblox

  @roblox_game_url "https://www.roblox.com/games/"
  @default_fetch_delay 60

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Returns the preset game URL.

    ## Examples:

      iex> RobloxUpdatesBot.State.game_url()
      "https://www.roblox.com/games/"
  """
  @spec game_url() :: String.t()
  def game_url, do: @roblox_game_url

  @doc """
  Adds a game to the Watch list.

    Returns {:ok, "(game_universe_id)"} if success.

    ## Examples:

    iex> RobloxUpdateBot.State.add_game("https://www.roblox.com/games/18668065416")
    {:ok, "6325068386"}
  """
  @spec add_game(String.t()) :: {:ok, String.t()} | {:error, :not_roblox_game} | {:error, :already_added}
  def add_game(game_link) do
    case String.starts_with?(game_link, @roblox_game_url) do
      true ->
        universe_id = Roblox.extract_universe_id_from_url(game_link)
        GenServer.call(__MODULE__, {:add, universe_id})

      _ ->
        {:error, :not_roblox_game}
    end
  end

  @doc """
  Removes a game from the Watch list.

    Returns {:ok, "(game_universe_id)"} if success.

    ## Examples:

    iex> RobloxUpdateBot.State.remove_game("https://www.roblox.com/games/18668065416")
    {:ok, "6325068386"}

    iex> RobloxUpdateBot.State.remove_game("https://www.roblox.com/games/18668065416")
    {:error, :not_found}
  """
  @spec remove_game(String.t()) :: {:ok, String.t()} | {:error, :not_roblox_game} | {:error, :not_found}
  def remove_game(game_link) do
    case String.starts_with?(game_link, @roblox_game_url) do
      true ->
        universe_id = Roblox.extract_universe_id_from_url(game_link)
        GenServer.call(__MODULE__, {:remove, universe_id})

      _ ->
        {:error, :not_roblox_game}
    end
  end

  def get_updated_games_date do
    GenServer.call(__MODULE__, :get_updated_games_date)
  end

  def get_updates_date do
    GenServer.call(__MODULE__, :get_updates_date)
  end

  def update_game_date(universe_id, new_date) do
    GenServer.cast(__MODULE__, {:update_universe_date, universe_id, new_date})
  end

  def fetch_game_info(universe_id) do
    GenServer.call(__MODULE__, {:game_info, universe_id})
  end

  def get_fetch_delay do
    GenServer.call(__MODULE__, :get_fetch_delay)
  end

  def update_fetch_delay(value) do
    GenServer.cast(__MODULE__, {:update_fetch_delay, value})
  end

  def get_send_channel_id do
    GenServer.call(__MODULE__, :get_channel_id)
  end

  def update_channel_id(channel_id) do
    GenServer.cast(__MODULE__, {:update_channel_id, channel_id})
    channel_id
  end

  # Server

  @impl true
  def init(_) do
    {:ok,
     %{
       universe_ids: [],
       last_update_date: %{},
       games_cache: %{},
       channel_id: nil,
       fetch_delay: @default_fetch_delay
     }}
  end

  defp insert_new_game(
         %{
           universe_ids: universe_ids,
           last_update_date: last_update_date,
           games_cache: games_cache
         } = state,
         universe_id
       ) do
    state
    |> Map.put(:universe_ids, [universe_id | universe_ids])
    |> Map.put(
      :last_update_date,
      Map.put(last_update_date, universe_id, Roblox.get_last_update_time(universe_id))
    )
    |> Map.put(
      :games_cache,
      Map.put(games_cache, universe_id, Roblox.get_universe_info(universe_id))
    )
  end

  @impl true
  def handle_call({:add, universe_id}, _from, %{universe_ids: universe_ids} = state) do
    case Enum.member?(universe_ids, universe_id) do
      true -> {:reply, {:error, :already_added}, state}
      false -> {:reply, {:ok, universe_id}, insert_new_game(state, universe_id)}
    end
  end

  def handle_call({:remove, universe_id}, _from, %{universe_ids: universe_ids} = state) do
    case Enum.member?(universe_ids, universe_id) do
      false ->
        {:reply, {:error, :not_found}, state}

      true ->
        {:reply, {:ok, universe_id},
         Map.put(
           state,
           :universe_ids,
           Enum.filter(universe_ids, fn u -> u !== universe_id end)
         )}
    end
  end

  def handle_call(:get_updated_games_date, _from, %{universe_ids: universe_ids} = state) do
    {:reply, Roblox.get_last_update_time(universe_ids), state}
  end

  def handle_call(:get_updates_date, _from, %{last_update_date: last_update_date} = state) do
    {:reply, last_update_date, state}
  end

  def handle_call({:game_info, universe_id}, _from, %{games_cache: games_cache} = state) do
    game_info = Map.get(games_cache, universe_id)
    {:reply, game_info, state}
  end

  def handle_call(:get_fetch_delay, _from, %{fetch_delay: fetch_delay} = state),
    do: {:reply, fetch_delay, state}

  def handle_call(:get_channel_id, _from, %{channel_id: channel_id} = state),
    do: {:reply, channel_id, state}

  @impl true
  def handle_cast(
        {:update_universe_date, universe_id, new_date},
        %{last_update_date: last_update_date} = state
      ) do
    new_last_update_date = Map.put(last_update_date, universe_id, new_date)

    new_state =
      state
      |> Map.put(:last_update_date, new_last_update_date)

    {:noreply, new_state}
  end

  def handle_cast({:update_fetch_delay, value}, state) do
    {:noreply, Map.put(state, :fetch_delay, value)}
  end

  def handle_cast({:update_channel_id, channel_id}, state) do
    {:noreply, Map.put(state, :channel_id, channel_id)}
  end
end
