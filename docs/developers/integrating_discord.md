---
id: integrating_discord
title: Integrating Discord
sidebar_label: Integrating Discord
---
The LMS offers basic Discord integration, allowing you to cache messages from any user who has linked their Discord profile from a specific server. Additionally, you can modify user roles.

### Setting the configuration
To set up Discord integration, you will need to configure the settings for your school.

Here are the steps:

#### Step 1: Create a Discord bot
You'll need to visit [Discord developer portal](https://discord.com/developers/applications/) and generate a new application there. Once you've created the application, enable the Presence Intent, Server Members Intent, and Message Content Intent under Privileged Gateway Intents.

#### Step 2: Generating Bot token
Once you have enabled the _Privileged Gateway Intents_, you and generate Bot token, copy it.

#### Step 3: Generating Bot joining url
On the portal dashboard, click on OAuth2 and select _bot_ under _OAuth2 URL Generator_ and then select appropraite permission for the Bot. After spcifying the permission, go to the joining link which will redirect you to chossing the server where you want to add this bot.

#### Step 4: Getting server id
On Discord portal dashboard navigate to server settings. Copy the server ID from there.

#### Step 5: Save the token and server id
Now that you've copied the bot token and server ID, let's store them in the school's configuration.
```ruby
discord_config = {
  "discord" => {
    "bot_token" => "your_bot_token",
    "server_id" => "your_server_id"
  }
}

YOUR_SCHOOL_ID = 123

school = School.find(YOUR_SCHOOL_ID)

school.update!(school.configuration.merge(discord_config))
```

### Step 6: Start the bot
After specifying the discord configuration, all we need to do is start the bot.

```shell
bin/rails discord_bot
```
