defmodule RobloxUpdatesBot.Discord do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias Nostrum.Struct.Guild.Member
  alias Nostrum.Cache.GuildCache

  defp is_member_admin?(guild_id, member) do
    guild = GuildCache.get!(guild_id)
    Member.guild_permissions(member, guild)
    |> Enum.member?(:administrator)
  end

  defp convert_content_to_command(content) do
    split = content
    |> String.split(" ")
    {hd(split), tl(split)}
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws}) do
    admin = is_member_admin?(msg.guild_id, msg.member)
    convert_content_to_command(msg.content)
    |> check_command(admin, msg)
  end

  defp check_command({".add", args}, true, msg) do
    %{channel_id: channel_id} = msg
    game_link = hd(args)
    case RobloxUpdatesBot.Worker.add_game(game_link) do
      {:ok, _} -> Api.create_message(channel_id, "Added #{game_link} to watch list.")
      {:error, :not_roblox_game} -> Api.create_message(channel_id, "Please provide a valid Roblox game URL.")
      {:error, :already_added} -> Api.create_message(channel_id, "This game was already added. To remove, use .remove (game)")
    end
  end
  defp check_command(_, false, _), do: :no_admin
  defp check_command(_, _, _), do: :no_command
end
