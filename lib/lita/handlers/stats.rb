module Lita
  module Handlers
    class Stats < Handler
      route(/\Aleaderboard\?\z/, :leaderboard, command: true)

      def leaderboard(response)
        ActiveRecord::Base.connection_pool.with_connection do
          response.reply('Please wait while I fetch the leaderboard for you :simple_smile:')
          begin
            message = "Here is the latest published leaderboard:%0A#{ranked_list_of_startups}"
            RestClient.get "https://slack.com/api/chat.postMessage?"\
            "token=#{APP_CONFIG[:slack_token]}&channel=#{response.message.source.room}"\
            "&text=#{message}&as_user=true"
          rescue
            response.reply(':confused: Oops! Something seems wrong. Please try again later!')
          end
        end
      end

      def ranked_list_of_startups
        rank_list = ''
        ranked_startups = Startup.leaderboard_of_batch Batch.current
        ranked_startups.each do |startup_id, rank|
          rank_list += "#{rank}. <#{Rails.application.routes.url_helpers.startup_url(Startup.find(startup_id))}|#{Startup.find(startup_id).product_name}>%0A"
        end
        unranked_startups = Startup.without_karma_and_rank_for_batch Batch.current
        unranked_startups[0].each do |startup|
          rank_list += "#{ranked_startups.length + 1}. <#{Rails.application.routes.url_helpers.startup_url(startup)}|#{startup.product_name}>%0A"
        end
        rank_list
      end
    end

    Lita.register_handler(Stats)
  end
end
