module Lita
  module Handlers
    class Backup < Handler
      on :unhandled_message do |payload|
        message = payload[:message]
        p payload.keys
        p(payload[:message].methods - Object.methods)
        puts message.body
        puts "User: #{message.user} (#{message.user.name}) [#{message.user.mention_name}]"
        puts "Source: #{message.source}"
        message.reply_with_mention 'Message recorded.'
      end

      Lita.register_handler(self)
    end
  end
end
