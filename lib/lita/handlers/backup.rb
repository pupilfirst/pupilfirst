module Lita
  module Handlers
    class Backup < Handler
      on :unhandled_message do |payload|
        ActiveRecord::Base.connection_pool.with_connection do
          message = payload[:message]

          next if message.private_message?

          message_author_slack_username = message.user.mention_name
          message_author = ::Founder.find_by slack_username: message_author_slack_username

          # TODO: Channel name should be accessible directly from message.room_object.name, but it isn't. Fix when possible.
          # See: https://github.com/kenjij/lita-slack/issues/44
          channel = Lita::Room.find_by_id(message.room_object.id).name

          PublicSlackMessage.create! body: message.body, slack_username: message.user.mention_name, founder: message_author, channel: channel
        end
      end

      Lita.register_handler(self)
    end
  end
end
