module Lita
  module Handlers
    class Activity < Handler
      route(/\Aactivity\?\z/, :activity, command: true)

      def activity(response)
        active_users = PublicSlackMessage.users_active_last_hour.batched
        user_names = active_users.present? ? "(@" + active_users.map(&:slack_username).join(', @') + ")" : ""
        active_startups = Startup.find active_users.select(:startup).distinct.pluck(:startup_id)
        startup_names = active_startups.present? ? "(" + active_startups.map(&:product_name).join(', ') + ")" : ""
        response.reply_privately(
          "Here's activity for the last hour:",
          "batch founders active: " + active_users.count.to_s + user_names,
          "batch startups active: " + active_startups.count.to_s + startup_names)
      end
    end

    Lita.register_handler(Activity)
  end
end
