module Lita
  module Handlers
    class Stats < Handler
      route(/\Aleaderboard\?\z/, :leaderboard, command: true)

      def leaderboard(response)
        ActiveRecord::Base.connection_pool.with_connection do
          response.reply(
            "Last Published Leaderboard:",
            ranked_list_of_startups
          )
        end
      end

      def ranked_list_of_startups
        rank_list = ''
        ranked_startups = Startup.leaderboard_of_batch Batch.first
        ranked_startups.each do |startup_id, rank|
          rank_list += "#{rank}. #{Startup.find(startup_id).product_name}\n"
        end
        unranked_startups = Startup.without_karma_and_rank_for_batch Batch.first
        unranked_startups[0].each do |startup|
          rank_list += "#{ranked_startups.length + 1}. #{startup.product_name}\n"
        end
        rank_list
      end
    end

    Lita.register_handler(Stats)
  end
end
