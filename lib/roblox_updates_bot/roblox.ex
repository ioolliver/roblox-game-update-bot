defmodule RobloxUpdatesBot.Roblox do
  @roblox_games_api_url "https://games.roblox.com/v1/games"

  @spec extract_universe_id_from_url(String.t()) :: String.t()
  def extract_universe_id_from_url(url) do
    Req.get!(url)
    |> Map.get(:body)
    |> Floki.parse_document!()
    |> Floki.find("#game-detail-meta-data")
    |> Floki.attribute("data-universe-id")
    |> hd()
  end

  def get_last_update_time(universe_id) when is_binary(universe_id) do
    universe_id
    |> get_universe_info()
    |> Map.get("updated")
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

  def get_universe_info(universe_ids) when is_list(universe_ids) do
    Req.get!("#{@roblox_games_api_url}?universeIds=#{Enum.join(universe_ids, ",")}")
    |> Map.get(:body)
    |> Map.get("data")
  end

  def get_universe_info(universe_id) when is_binary(universe_id) do
    get_universe_info([universe_id])
    |> List.first()
  end
end
