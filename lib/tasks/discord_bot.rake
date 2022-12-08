require 'discorb'

desc 'Discord bot that listens to messages in a Discord server and saves them to the database'
task discord_bot: [:environment] do
  ## Experimental feature
  ## this is a task that runs a Discord bot that listens to messages in a Discord server
  ## and saves them to the database
  ## It does not support multiple schools yet, its possible by identifying the school from
  ## the server id, but it's not implemented yet as we don't have a use case for it yet.
  # TODO: add support for multiple schools
  school_id = ENV['SCHOOL_ID_FOR_DISCORD_BOT']
  school = School.find_by(id: school_id)

  return if school.blank?

  discord_configuration = Schools::Configuration::Discord.new(school)

  if discord_configuration.configured?
    intents = Discorb::Intents.new

    # The message_content intent is required to receive message content
    intents.message_content = true
    client = Discorb::Client.new(intents: intents)

    # Fancy way to initialize the bot
    client.once :standby do
      puts "Logged in as #{client.user} in #{school.name} school discord server"
    end

    client.on :message do |message|
      # Log the event type

      puts "Event #{message.type} received with ID #{message.id}"

      # We only want to listen to default messages type in the current implementation
      # This ensures that we don't log thread creation messages
      next if message.type != :default

      # The messages should belong to the school's server & we should ignore messages sent as dm to the bot
      next unless message.guild&.id == discord_configuration.server_id

      # The author of the message should be a user in the school
      user =
        User.find_by(discord_user_id: message.author.id, school_id: school_id)

      next if user.blank?

      # A catch in channles is that threads are also channels inside a channel, the channel uuid
      # for a message in a thread is the channel id of the thread, not the channel id of the parent channel
      DiscordMessage
        .where(message_uuid: message.id)
        .first_or_create!(
          author_uuid: message.author.id,
          channel_uuid: message.channel.id,
          server_uuid: message.guild.id,
          content: message.content,
          timestamp: message.timestamp,
          user: user
        )

      puts "Event #{message.type} received with ID #{message.id} from author #{message.author.id} in channel #{message.channel.id}"
    end

    client.run("Bot #{discord_configuration.bot_token}")
  end
end
