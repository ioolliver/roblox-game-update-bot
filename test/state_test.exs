defmodule RobloxUpdatesBotTest.State do
  @moduledoc false
  use ExUnit.Case

  alias RobloxUpdatesBot.State

  describe "add_game/1" do
    test "when a valid url game is provided, returns {:ok, universe_id} and game is added to State cache" do
      url = "https://www.roblox.com/games/18668065416"
      {:ok, universe_id} = State.add_game(url)
      assert is_map(State.fetch_game_info(universe_id))
    end
    test "when a repeated url game is provided, returns {:error, :already_added}" do
      url = "https://www.roblox.com/games/3398014311"
      {:ok, universe_id} = State.add_game(url)
      assert State.add_game(url) == {:error, :already_added}
    end
    test "when a non-roblox game url is provided, returns {:error, :not_roblox_game}" do
      url = "https://www.google.com"
      assert State.add_game(url) == {:error, :not_roblox_game}
    end
  end

  describe "remove_game/1" do
    test "when a existent game url is provided, returns {:ok, universe_id} and game is removed from the State" do
      url = "https://www.roblox.com/games/69184822"
      {:ok, universe_id} = State.add_game(url)
      {:ok, universe_id} = State.remove_game(url)
      assert {:error, :not_found} == State.remove_game(url)
    end
  end
end
