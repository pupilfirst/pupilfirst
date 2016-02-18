module Lita
  module Handlers
    class Activity < Handler
      route(/\Aactivity\?\z/, :activity, command: true, restrict_to: :sv_co_team)

      def activity(response)
        ActiveRecord::Base.connection_pool.with_connection do
          response.reply(
            "Here's activity for the last hour:",
            'Total active founders: ' + active_founders.count.to_s,
            'Batch founders active: ' + active_batched_founders.count.to_s + founder_names,
            'Batch startups active: ' + active_startups.count.to_s + startup_names
          )
        end
      end

      private

      def active_founders
        PublicSlackMessage.founders_active_last_hour
      end

      def active_batched_founders
        active_founders.batched
      end

      def founder_names
        active_batched_founders.present? ? '(@' + active_batched_founders.map(&:slack_username).join(', @') + ')' : ''
      end

      def active_startups
        Startup.find active_batched_founders.select(:startup).distinct.pluck(:startup_id)
      end

      def startup_names
        active_startups.present? ? '(' + active_startups.map(&:product_name).join(', ') + ')' : ''
      end
    end

    Lita.register_handler(Activity)
  end
end
