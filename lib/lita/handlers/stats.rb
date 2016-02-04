module Lita
  module Handlers
    class Stats < Handler
      route(/\Aleaderboard\? *(\d*)\z/, :leaderboard, command: true)

      def leaderboard(response)
        ActiveRecord::Base.connection_pool.with_connection do
          # check if a particular batch was requested by parsing the regex matches
          @batch_requested = response.match_data[1].present? ? response.match_data[1].to_i : nil

          # reply immediately with a relevant 'please wait' message
          if @batch_requested.present?
            response.reply("Please wait while I fetch the leaderboard for Batch #{@batch_requested} :simple_smile:")
          else
            response.reply('Please wait while I fetch the leaderboards of all current batches for you :simple_smile:')
          end

          begin
            if response.message.source.private_message
              # respond directly to the user if private message
              slack_username = response.message.source.user.metadata['mention_name']
              user = ::User.find_by(slack_username: slack_username)
              PublicSlackTalk.post_message message: leaderboard_response_message, user: user
            else
              # reply to the source channel if not a private message
              channel = response.message.source.room
              PublicSlackTalk.post_message message: leaderboard_response_message, channel: channel
            end
          rescue
            response.reply(':confused: Oops! Something seems wrong. Please try again later!')
          end
        end
      end

      # construct the leaderboard response to be send
      def leaderboard_response_message
        return '_There appears to be no live batches on SV.CO now !_' unless Batch.live.present?
        if @batch_requested && !Batch.live.where(batch_number: @batch_requested).present?
          return "_There appears to be no live Batch #{@batch_requested} on SV.CO now !_"
        end

        # Build response considering batch requested, if any
        response = ''
        batches = @batch_requested.present? ? Batch.where(batch_number: @batch_requested) : Batch.live
        batches.each do |batch|
          response += "*<#{Rails.application.routes.url_helpers.about_leaderboard_url}\
          |Latest published leaderboard for Batch #{batch.batch_number} (#{batch.name})>:* \n#{ranked_list_for_batch batch}"
        end

        response
      end

      def ranked_list_for_batch(batch)
        rank_list = ''
        ranked_startups = Startup.leaderboard_of_batch batch
        ranked_startups.each do |startup_id, rank|
          rank_list += "#{rank}. <#{Rails.application.routes.url_helpers.startup_url(Startup.find(startup_id))}|#{Startup.find(startup_id).product_name}>\n"
        end
        unranked_startups = Startup.without_karma_and_rank_for_batch batch
        unranked_startups[0].each do |startup|
          rank_list += "#{ranked_startups.length + 1}. <#{Rails.application.routes.url_helpers.startup_url(startup)}|#{startup.product_name}>\n"
        end
        rank_list
      end
    end

    Lita.register_handler(Stats)
  end
end
