module Lita
  module Handlers
    class Stats < Handler
      route(
        /\Astate of SV.CO for batch *(\d*) *\?\z/,
        :state_of_batch,
        command: true,
        help: { 'state of SV.CO for batch N?' => I18n.t('slack.help.state_of_svco') }
      )

      def state_of_batch(response)
        # lets avoid the need to pass response around
        @response = response

        ActiveRecord::Base.connection_pool.with_connection do
          @batch_requested = @response.match_data[1].present? ? ::Batch.find_by_batch_number(@response.match_data[1].to_i) : nil

          # respond with error if batch number missing
          @batch_requested.present? ? reply_with_state_of_batch : send_batch_missing_message
        end
      end

      def send_batch_missing_message
        @response.reply 'Please specify a batch number! eg: `state of SV.CO for batch 1?`'
      end

      def reply_with_state_of_batch
        @response.reply batch_state_message
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
        "#{@batch_requested.startups.count} #{names_list}\n"
      end

      def stage_wise_startup_counts_and_names
        response = ''
        stages = @batch_requested.startups.pluck(:stage).uniq

        stages.each do |stage|
          response += 'Number of startups in _\'' + I18n.t("timeline_event.stage.#{stage}") + '\'_ stage: '
          startups = Startup.where(stage: stage, batch: @batch_requested)
          response += startups.count.to_s + " #{list_of_names(startups)}\n"
        end

        response
      end

      def inactive_startups_count_and_names
        startups = @batch_requested.startups.inactive_for_week
        names_list = list_of_names(startups)
        "#{startups.count} #{names_list}\n"
      end

      def endangered_startups_count_and_names
        startups = @batch_requested.startups.endangered
        names_list = list_of_names(startups)
        "#{startups.count} #{names_list}\n"
      end

      def list_of_names(startups)
        return '' unless startups.present?
        '(' + startups.map { |startup| "<#{Rails.application.routes.url_helpers.startup_url(startup)}|#{startup.product_name}>" }.join(', ') + ')'
      end
    end

    Lita.register_handler(Stats)
  end
end
