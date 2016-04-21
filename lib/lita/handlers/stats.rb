module Lita
  module Handlers
    class Stats < Handler
      route(/\Astate of SV.CO for batch *(\d*) *\?\z/, :state_of_batch, command: true, restrict_to: :sv_co_team)

      def state_of_batch(response)
        # lets avoid the need to pass response around
        @response = response

        ActiveRecord::Base.connection_pool.with_connection do
          @batch_requested = @response.match_data[1].present? ? ::Batch.find_by_batch_number(@response.match_data[1].to_i) : nil

          # respond with error if batch number missing
          unless @batch_requested.present?
            send_batch_missing_message
            return
          end

          @response.message.source.private_message ? send_stats_privately : send_stats_to_channel
        end
      end

      def send_batch_missing_message
        @response.reply('Please specify a batch number! eg: `stats for batch 1`')
      end

      def send_stats_privately
        slack_username = @response.message.source.user.metadata['mention_name']
        founder = ::Founder.find_by(slack_username: slack_username)

        if founder
          PublicSlackTalk.post_message message: batch_state_message, founder: founder
        else
          reply_using_api_post_message channel: response.message.source.room, message: batch_state_message
        end
      end

      def send_stats_to_channel
        channel = @response.message.source.room
        PublicSlackTalk.post_message message: batch_state_message, channel: channel
      end

      def batch_state_message
        <<~STATS_MESSAGE
          > *State of SV.CO Batch #{@batch_requested.batch_number} (#{@batch_requested.name}):*
          Total number of startups: #{total_startups_count_and_names}
          #{stage_wise_startup_counts_and_names}
          Number of inactive startups last week: #{inactive_startups_count_and_names}
          Number of startups in danger zone: #{endangered_startups_count_and_names}
        STATS_MESSAGE
      end

      def total_startups_count_and_names
        names_list = list_of_names(@batch_requested.startups)
        "#{@batch_requested.startups.count} (#{names_list})\n"
      end

      def stage_wise_startup_counts_and_names
        response = ''
        stages = @batch_requested.startups.pluck(:stage).uniq

        stages.each do |stage|
          response += 'Number of startups in _\'' + I18n.t("timeline_event.stage.#{stage}") + '\'_ stage: '
          startups = Startup.where(stage: stage, batch: @batch_requested)
          response += startups.count.to_s + " (#{list_of_names(startups)})\n"
        end

        response
      end

      def inactive_startups_count_and_names
        startups = @batch_requested.startups.inactive_for_week
        names_list = list_of_names(startups)
        "#{startups.count} (#{names_list})\n"
      end

      def endangered_startups_count_and_names
        startups = @batch_requested.startups.endangered
        names_list = list_of_names(startups)
        "#{startups.count} (#{names_list})\n"
      end

      def list_of_names(startups)
        startups.map { |startup| "<#{Rails.application.routes.url_helpers.startup_url(startup)}|#{startup.product_name}>" }.join(', ')
      end

      def reply_using_api_post_message(channel:, message:)
        RestClient.get "https://slack.com/api/chat.postMessage?token=#{APP_CONFIG[:slack_token]}&channel=#{channel}"\
        "&text=#{CGI.escape message}&as_user=true"
      end
    end

    Lita.register_handler(Stats)
  end
end
