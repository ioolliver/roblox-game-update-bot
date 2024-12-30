import Config

config :nostrum,
  gateway_intents: [:message_content, :guild_messages, :guild_members, :guilds]

import_config "secret.exs"
