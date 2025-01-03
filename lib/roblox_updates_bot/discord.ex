defmodule RobloxUpdatesBot.Discord do
  use Nostrum.Consumer

  require Logger
  alias Nostrum.Api
  alias Nostrum.Struct.Guild.Member
  alias Nostrum.Cache.GuildCache

  defp is_member_admin?(guild_id, member) do
    guild = GuildCache.get!(guild_id)

    Member.guild_permissions(member, guild)
    |> Enum.member?(:administrator)
  end

  defp convert_content_to_command(content) do
    split =
      content
      |> String.split(" ")

    {hd(split), tl(split)}
  end

  def game_updated(game) do
    %{"name" => name, "rootPlaceId" => root_id} = game

    case RobloxUpdatesBot.State.get_send_channel_id() do
      nil ->
        Logger.log(
          :warning,
          "Game \"#{name}\" updated but no share channel is set. Please use .channel on some channel in Discord."
        )

      channel ->
        Api.create_message(
          channel,
          "[⭐] FRESH UPDATE ON **#{name}**\n\nCHECK OUT NOW!\n\n#{RobloxUpdatesBot.State.game_url()}#{root_id}"
        )
    end
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws}) do
    admin = is_member_admin?(msg.guild_id, msg.member)

    convert_content_to_command(msg.content)
    |> check_command(admin, msg)
  end

  defp check_command({".add", args}, true, msg) do
    %{channel_id: channel_id} = msg
    game_link = hd(args)

    case RobloxUpdatesBot.State.add_game(game_link) do
      {:ok, _} ->
        Api.create_message(channel_id, "Added game to watch list.\n\n#{game_link}")

      {:error, :not_roblox_game} ->
        Api.create_message(channel_id, "Please provide a valid Roblox game URL.")

      {:error, :already_added} ->
        Api.create_message(
          channel_id,
          "This game was already added. To remove, use .remove (game)"
        )
    end
  end

  defp check_command({".remove", args}, true, msg) do
    %{channel_id: channel_id} = msg
    game_link = hd(args)

    case RobloxUpdatesBot.State.remove_game(game_link) do
      {:ok, _} ->
        Api.create_message(channel_id, "Removed game from watch list.")

      {:error, :not_roblox_game} ->
        Api.create_message(channel_id, "Please provide a valid Roblox game URL.")

      {:error, :not_found} ->
        Api.create_message(
          channel_id,
          "This game is not in watch list. If you want to add, use .add (game)"
        )
    end
  end

  defp check_command({".delay", args}, true, msg) do
    %{channel_id: channel_id} = msg
    delay = hd(args)

    case Integer.parse(delay) do
      {value, _} ->
        RobloxUpdatesBot.State.update_fetch_delay(value)
        Api.create_message(channel_id, "Checking for updates every #{value} seconds from now.")

      _ ->
        Api.create_message(channel_id, "Please use .delay (number in seconds)")
    end
  end

  defp check_command({".channel", _args}, true, %{channel_id: channel_id}) do
    channel_id
    |> RobloxUpdatesBot.State.update_channel_id()
    |> Api.create_message("This channel will be the updates channel from now.")
  end

  defp check_command(_, false, _), do: :no_admin
  defp check_command(_, _, _), do: :no_command
end
