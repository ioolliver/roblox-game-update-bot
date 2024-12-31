# RobloxUpdatesBot

A Discord BOT that watch for Roblox games updates and notify in a specific channel when a game gets updated.

## Installation

You will need [Elixir](https://elixir-lang.org/install.html#windows) installed on your machine.

Clone the project to your machine:
`git clone https://github.com/ioolliver/roblox-game-update-bot`

Inside the directory, installs the dependecies:
`mix deps.get`

Create a file named `secret.exs` inside the config folder. There, paste this code:
```elixir import Config

config :nostrum,
  token: "YOUR_BOT_TOKEN"```

To start your project, runs:
`mix run --no-halt`