module Lita
  module Handlers
    class Backup < Handler
      on :unhandled_message do |payload|
        ActiveRecord::Base.connection_pool.with_connection do
          record_message(payload)
        end
      end

      on :slack_reaction_added do |payload|
        ActiveRecord::Base.connection_pool.with_connection do
          record_reaction(payload)
        end
      end

      on :slack_reaction_removed do |payload|
        ActiveRecord::Base.connection_pool.with_connection do
          remove_reaction(payload)
        end
      end

      def record_message(payload)
        message = payload[:message]

        # do not backup private messages
        return if message.private_message?

        message_author_slack_username = message.user.mention_name
        message_author = ::Founder.find_by slack_username: message_author_slack_username

        # TODO: Channel name should be accessible directly from message.room_object.name, but it isn't. Fix when possible.
        # See: https://github.com/kenjij/lita-slack/issues/44
        # Alert: As mentioned in link above, the following approach to extract channel will fail for private messages.
        channel = Lita::Room.find_by_id(message.room_object.id).try(:name) # rubocop:disable Rails/DynamicFindBy

        PublicSlackMessage.create!(
          body: message.body, slack_username: message.user.mention_name, founder: message_author, channel: channel,
          timestamp: message.extensions[:slack][:timestamp]
        )
      end

      def record_reaction(payload)
        # dont bother if reaction is not towards a message
        return unless payload[:item]['type'] == 'message'

        # dont bother if the message reacted to cant be found in our db
        reaction_to = ::PublicSlackMessage.find_by(timestamp: payload[:item]['ts'])
        return if reaction_to.blank?

        # extract details from payload
        reaction_author_slack_username = payload[:user].metadata['mention_name']
        reaction_author = ::Founder.find_by slack_username: reaction_author_slack_username
        timestamp = payload[:event_ts]
        channel = reaction_to.channel
        body = ":#{payload[:name]}:"

        # save the reaction as a PublicSlackMessage with appropriate details
        PublicSlackMessage.create!(
          body: body, slack_username: reaction_author_slack_username, founder: reaction_author, channel: channel,
          reaction_to: reaction_to, timestamp: timestamp
        )
      end

      def remove_reaction(payload)
        # dont bother if reaction is not towards a message
        return unless payload[:item]['type'] == 'message'

        # dont bother if the message reacted to cant be found in our db
        reaction_to = ::PublicSlackMessage.find_by(timestamp: payload[:item]['ts'])
        return if reaction_to.blank?

        # dont bother if the removed reaction could not be found
        removed_reaction = reaction_to.reactions.where(slack_username: payload[:user].metadata['mention_name'], body: ":#{payload[:name]}:").first
        return if removed_reaction.blank?

        # Delete the reaction to be removed
        removed_reaction.destroy
      end

      Lita.register_handler(self)
    end
  end
end
