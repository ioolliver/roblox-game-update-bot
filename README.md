# RobloxUpdatesBot

A Discord BOT that watches for Roblox games updates and notifies a specific channel when a game is updated.

## Installation

You will need [Elixir](https://elixir-lang.org/install.html#windows) installed on your machine.

Clone the project to your machine:
```
git clone https://github.com/ioolliver/roblox-game-update-bot
```

Go to the directory:

```
cd roblox-game-update-bot
```

Inside the directory, installs the dependecies:
```
mix deps.get
```

Create a file named `secret.exs` inside the config folder. There, paste this code:
```elixir 
import Config

config :nostrum,
  token: "YOUR_BOT_TOKEN"
```

To start your project, runs:
```
mix run --no-halt
```

## Commands

### Add

This command adds a new game to Watch list. You need administrative rights for this.

![A Example of the .add command](https://i.imgur.com/vgA4MQY.png)

### Remove

This command removes a game from Watch list. You need administrative rights for this.

![A Example of the .remove command](https://i.imgur.com/X2b4SFz.png)

### Channel

This command sets the channel for sending updates. If you don't set it, game updates will not be notified.

![A Example of the .channel command](https://i.imgur.com/spYphnE.png)

### Delay

This command changes the timeout for checking for updates (Every x seconds, check for updates). Default is 60 seconds.

![A Example of the .delay command](https://i.imgur.com/hBhVuY6.png)

## Update preview

When a game updates, BOT will send a message like this on updates channel:

![A Game updated example](https://i.imgur.com/etqtTlI.png)

## Support

If you need help, add me on Discord:
`salgadodoxe.`
