module Lita
  module Handlers
    class Activity < Handler
      route(/\Aactivity?\z/, :greet, command: true)

      def greet(response)
        count = PublicSlackMessage.active_last_hour
        response.reply("There were " + count.to_s + " active users in the last hour!")
      end
    end

    Lita.register_handler(Activity)
  end
end
