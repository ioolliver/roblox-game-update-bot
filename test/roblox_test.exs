defmodule RobloxUpdatesBotTest.Roblox do
  @moduledoc false
  use ExUnit.Case

  alias RobloxUpdatesBot.Roblox

  describe "extract_universe_id_from_url/1" do
    test "when a valid game url is provided, returns the game's universe ID." do
      expected_universe_id = "994732206"
      url = "https://www.roblox.com/games/2753915549"
      assert Roblox.extract_universe_id_from_url(url) == expected_universe_id
    end

    test "when a invalid game url is provided, returns nil" do
      url = "https://www.google.com"
      assert Roblox.extract_universe_id_from_url(url) == nil
    end
  end

  describe "get_universe_info/1" do
    test "when a valid single universe ID is provided, returns the game info." do
      universe_id = "994732206"
      info = Roblox.get_universe_info(universe_id)
      assert is_map(info)
      assert is_number(info["id"])
      assert is_binary(info["updated"])
    end

    test "when a multiples universes IDs are provided, returns the games info in a list." do
      universe_ids = ["994732206", "6401952734"]
      info = Roblox.get_universe_info(universe_ids)
      assert is_list(info)
      assert length(info) == 2
      [game1 | [game2 | []]] = info
      assert is_map(game1)
      assert is_map(game2)
      assert is_number(game1["id"])
      assert is_number(game2["id"])
      assert is_binary(game1["updated"])
      assert is_binary(game2["updated"])
    end

    test "when a invalid single universe ID is provided, returns nil." do
      universe_id = "invalid"
      info = Roblox.get_universe_info(universe_id)
      assert info == nil
    end

    test "when multiple invalid universes ID are provided, ignores the invalid ones and return a list with the valid ones." do
      universe_ids = ["invalid", "994732206", "invalid2", "6401952734"]
      info = Roblox.get_universe_info(universe_ids)
      assert is_list(info)
      assert length(info) == 2
      assert is_map(List.first(info))
    end
  end

  describe "get_last_update_time/1" do
    test "when a valid single universe ID is provided, returns the last update time." do
      universe_id = "994732206"
      info = Roblox.get_last_update_time(universe_id)
      assert is_binary(info)
    end
    test "when a invalid single universe ID is provided, returns nil." do
      universe_id = "invalid"
      assert Roblox.get_last_update_time(universe_id) == nil
    end
    test "when valid multiple universes IDs are provided, returns a list with the game ID and it updated date." do
      universe_ids = ["994732206", "6401952734"]
      info = Roblox.get_last_update_time(universe_ids)
      assert is_list(info)
      assert length(info) == 2
      [game1 | [game2]] = info
      assert is_tuple(game1)
      assert is_tuple(game2)
    end
    test "when multiple invalid universes ID are provided, ignores the invalid ones and return a list with the valid ones." do
      universe_ids = ["invalid", "994732206", "invalid2", "6401952734"]
      info = Roblox.get_last_update_time(universe_ids)
      assert is_list(info)
      assert length(info) == 2
      assert is_tuple(List.first(info))
    end
  end
end
