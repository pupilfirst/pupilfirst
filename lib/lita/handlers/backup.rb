module Lita
  module Handlers
    class Backup < Handler
      on :unhandled_message do |payload|
        message = payload[:message]
        message_author_slack_username = message.user.mention_name
        message_author = ::User.find_by slack_username: message_author_slack_username
        PublicSlackMessage.create! body: message.body, slack_username: message.user.mention_name, user: message_author
      end

      Lita.register_handler(self)
    end
  end
end
