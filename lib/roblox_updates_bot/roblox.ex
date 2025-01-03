defmodule RobloxUpdatesBot.Roblox do
  @moduledoc """
  This module is able to make interactions with the Roblox API.

  ## Examples

      iex> RobloxUpdatesBot.Roblox.extract_universe_id_from_url("https://www.roblox.com/games/2753915549")
      "994732206"
  """

  @roblox_games_api_url "https://games.roblox.com/v1/games"

  @doc """
  Extracts the universe ID from a given url. Universe ID will be used later to retrieving game info, such as Update date and name, in Roblox API.

  Returns the game Universe ID.

  ## Examples

      iex> RobloxUpdatesBot.Roblox.extract_universe_id_from_url("https://www.roblox.com/games/2753915549")
      "994732206"

  """
  @spec extract_universe_id_from_url(String.t()) :: String.t()
  def extract_universe_id_from_url(url) do
    Req.get!(url)
    |> Map.get(:body)
    |> Floki.parse_document!()
    |> Floki.find("#game-detail-meta-data")
    |> Floki.attribute("data-universe-id")
    |> get_universe_id
  end

  defp get_universe_id([]), do: nil
  defp get_universe_id(attributes) when is_list(attributes), do: hd(attributes)

  @doc """
  Gets game info from API with the givens Universes IDs.

  ## Examples

      iex> RobloxUpdatesBot.Roblox.get_universe_info("994732206")
      %{}

      iex> RobloxUpdatesBot.Roblox.get_universe_info(["994732206", "98742132"])
      [%{}, %{}]

  """
  @spec get_universe_info(String.t() | list(String.t())) :: map() | nil | list(map())
  def get_universe_info(universe_ids) when is_list(universe_ids) do
    sanitized_universe_ids = sanitize_universe_ids(universe_ids)

    Req.get!("#{@roblox_games_api_url}?universeIds=#{sanitized_universe_ids}")
    |> Map.get(:body)
    |> Map.get("data")
  end

  def get_universe_info(universe_id) when is_binary(universe_id) do
    get_universe_info([universe_id]) |> extract_single_universe_info
  end

  defp sanitize_universe_ids(universe_ids) do
    universe_ids
    |> Enum.filter(fn uid -> Integer.parse(uid) != :error && String.length(uid) < 15 end)
    |> Enum.join(",")
  end

  defp extract_single_universe_info(nil), do: nil
  defp extract_single_universe_info(universe_ids), do: hd(universe_ids)

  @doc """
  Get the last update time registred in the Roblox API from the given universe ID.

  ## Examples

      iex> RobloxUpdatesBot.Roblox.get_last_update_time("994732206")
      "date"

      iex> RobloxUpdatesBot.Roblox.get_last_update_time(["994732206", "98742132"])
      [{"994732206", "date"}, {"98742132", "date"}]

  """
  @spec get_last_update_time(String.t() | list(String.t())) ::
          String.t() | {String.t(), String.t()}
  def get_last_update_time(universe_id) when is_binary(universe_id) do
    universe_id
    |> get_universe_info()
    |> extract_update_time()
  end
  def get_last_update_time([]), do: []
  def get_last_update_time(universe_ids) when is_list(universe_ids) do
    universe_ids
    |> get_universe_info()
    |> Enum.map(fn u ->
      id = Map.get(u, "id") |> Integer.to_string()
      updated = Map.get(u, "updated")
      {id, updated}
    end)
  end

  defp extract_update_time(nil), do: nil
  defp extract_update_time(game), do: Map.get(game, "updated")
end
