module Lita
  module Handlers
    class Leaderboard < Handler
      route(/\Aleaderboard\s*\?*\s*(\d*)\s*\?*\z/i, :leaderboard, command: true, help: { 'leaderboard? [BATCH NUMBER]' => I18n.t('slack.help.leaderboard') })

      # rubocop:disable Metrics/AbcSize
      def leaderboard(response)
        ActiveRecord::Base.connection_pool.with_connection do
          # check if a particular batch was requested by parsing the regex matches
          @batch_requested = response.match_data[1].present? ? response.match_data[1].to_i : nil

          # reply immediately with a relevant 'please wait' message
          send_wait_message(response)

          begin
            # respond directly to the user if private message
            if response.message.source.private_message
              slack_username = response.message.source.user.metadata['mention_name']
              founder = ::Founder.find_by(slack_username: slack_username)

              # Fallback to using the SLACK postMessage API method for users who are not registered on SV.CO
              if founder
                PublicSlackTalk.post_message message: leaderboard_response_message, founder: founder
              else
                reply_using_api_post_message channel: response.message.source.room, message: leaderboard_response_message
              end

              # reply to the source channel if not a private message
            else
              channel = response.message.source.room
              reply_using_api_post_message message: leaderboard_response_message, channel: channel
            end

          rescue
            response.reply(':confused: Oops! Something seems wrong. Please try again later!')
          end
        end
      end

      # rubocop:enable Metrics/AbcSize

      # send a relevant please wait method
      def send_wait_message(response)
        if @batch_requested.present?
          response.reply("Please wait while I fetch the leaderboard for Batch #{@batch_requested} :simple_smile:")
        else
          response.reply('Please wait while I fetch the leaderboards of all current batches for you :simple_smile:')
        end
      end

      # reply to non-SV.CO users using the SLACK API directly
      def reply_using_api_post_message(channel:, message:)
        RestClient.get "https://slack.com/api/chat.postMessage?token=#{Rails.application.secrets.slack_token}&channel=#{channel}"\
        "&text=#{CGI.escape message}&as_user=true"
      end

      # construct the leaderboard response to be send
      def leaderboard_response_message
        return '_There appears to be no live batches on SV.CO now !_' unless Batch.live.present?
        if @batch_requested && !Batch.live.where(batch_number: @batch_requested).present?
          return "_There appears to be no live Batch #{@batch_requested} on SV.CO now !_"
        end

        # Build response considering batch requested, if any
        response = ''

        # TODO: The batch is hard-coded to Batch 3 for now. Replace with Batch.live when batches are cleaned up.
        batches = Batch.where(batch_number: 3)
        # batches = @batch_requested.present? ? Batch.where(batch_number: @batch_requested) : Batch.live
        batches.each do |batch|
          response += "*<#{Rails.application.routes.url_helpers.about_leaderboard_url}\
          |Latest published leaderboard for Batch #{batch.batch_number} (#{batch.name})>:* \n#{ranked_list_for_batch batch}"
        end

        response
      end

      def ranked_list_for_batch(batch)
        rank_list = ''
        ranked_startups = Startups::PerformanceService.new.leaderboard_with_change_in_rank(batch)
        ranked_startups.each do |startup, rank, _points, change_in_rank|
          indicator = if change_in_rank.negative?
            ':arrow_down_small:'
          elsif change_in_rank.positive?
            ':arrow_up_small:'
          else
            ':left_right_arrow:'
          end
          rank_list += "*#{format('%02d', rank)}.* (#{indicator} #{format('%+03d', change_in_rank)})  <#{Rails.application.routes.url_helpers.startup_url(startup)}|#{startup.product_name}>\n"
        end
        rank_list
      end
    end

    Lita.register_handler(Leaderboard)
  end
end
