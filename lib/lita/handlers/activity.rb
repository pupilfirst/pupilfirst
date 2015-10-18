module Lita
  module Handlers
    class Activity < Handler
      route(/\Aactivity\?\z/, :greet, command: true)

      def greet(response)
        active_users = PublicSlackMessage.users_active_last_hour.batched
        active_startups = Startup.find active_users.select(:startup).distinct.pluck(:startup_id)
        response.reply_privately(
          "Here's activity for the last hour:",
          "batch founders active: " + active_users.count.to_s,
          "batch startups active: " + active_startups.count.to_s)
      end
    end

    Lita.register_handler(Activity)
  end
end
