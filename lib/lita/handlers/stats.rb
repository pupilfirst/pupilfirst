module Lita
  module Handlers
    class Stats < Handler
      route(/\Aleaderboard\?\z/, :leaderboard, command: true)

      def leaderboard(response)
        ActiveRecord::Base.connection_pool.with_connection do
          response.reply('Please wait while I fetch the leaderboard for you :simple_smile:')
          begin
            message = "Here is the <#{Rails.application.routes.url_helpers.about_leaderboard_url}|latest published leaderboard>: \n#{ranked_list_of_startups}"

            if response.message.source.private_message
              # respond directly to the user if private message
              slack_username = response.message.source.user.metadata['mention_name']
              user = ActiveRecord::Base::User.find_by(slack_username: slack_username)
              PublicSlackTalk.post_message message: message, user: user
            else
              # reply to the source channel if not a private message
              channel = response.message.source.room
              PublicSlackTalk.post_message message: message, channel: channel
            end
            # RestClient.get "https://slack.com/api/chat.postMessage?"\
            # "token=#{APP_CONFIG[:slack_token]}&channel=#{response.message.source.room}"\
            # "&text=#{message}&as_user=true"
          rescue
            response.reply(':confused: Oops! Something seems wrong. Please try again later!')
          end
        end
      end

      def ranked_list_of_startups
        rank_list = ''
        ranked_startups = Startup.leaderboard_of_batch Batch.current
        ranked_startups.each do |startup_id, rank|
          rank_list += "#{rank}. <#{Rails.application.routes.url_helpers.startup_url(Startup.find(startup_id))}|#{Startup.find(startup_id).product_name}>\n"
        end
        unranked_startups = Startup.without_karma_and_rank_for_batch Batch.current
        unranked_startups[0].each do |startup|
          rank_list += "#{ranked_startups.length + 1}. <#{Rails.application.routes.url_helpers.startup_url(startup)}|#{startup.product_name}>\n"
        end
        rank_list
      end
    end

    Lita.register_handler(Stats)
  end
end
