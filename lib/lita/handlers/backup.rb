module Lita
  module Handlers
    class Backup < Handler
      on :unhandled_message do |payload|
        ActiveRecord::Base.connection_pool.with_connection do
          message = payload[:message]
          binding.pry

          next if message.private_message?

          message_author_slack_username = message.user.mention_name
          message_author = ::User.find_by slack_username: message_author_slack_username

          # TODO: Channel name should be accessible directly from message.room_object.name, but it isn't. Fix when possible.
          # See: https://github.com/kenjij/lita-slack/issues/44
          channel = Lita::Room.find_by_id(message.room_object.id).try(:name)

          # if reaction, fetch message reacted to
          parent_message = fetch_parent_message(message) if message.is_a? Reaction

          PublicSlackMessage.create! body: message.body, slack_username: message.user.mention_name,
            user: message_author, channel: channel, parent_message: parent_message, timestamp:
        end
      end

      def fetch_parent_message(message)
        PublicSlackMessage.find_by(channel: message.item['channel'], timestamp: message.item['ts'])
      end

      Lita.register_handler(self)
    end
  end
end
