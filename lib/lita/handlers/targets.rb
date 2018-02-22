module Lita
  module Handlers
    # TODO: This handler needs to be updated to fetch all targets for founder's startup's level.
    class Targets < Handler
      route(
        /^targets\s*\?*\s*info\s*(\d)\s*$|^targets\s*\?*\s*$/i,
        :targets_handler,
        command: true,
        help: {
          'targets' => I18n.t('libs.lita.handlers.targets.help'),
          'targets info [NUMBER]' => I18n.t('libs.lita.handlers.targets.help_info')
        }
      )

      attr_reader :response

      delegate :startup, to: :founder

      def targets_handler(response)
        @response = response

        ActiveRecord::Base.connection_pool.with_connection do
          if founder
            if command_value.present?
              reply_with_target_info
            else
              reply_with_targets_info
            end
          else
            response.reply_privately I18n.t('libs.lita.handlers.targets.unknown_username', slack_username: slack_username)
          end

          Ahoy::Tracker.new.track Visit::EVENT_VOCALIST_COMMAND, command: Visit::VOCALIST_COMMAND_TARGETS
        end
      end

      private

      def command_value
        response.match_data[1]
      end

      def target_number
        command_value.to_i
      end

      def reply_with_target_info
        if chosen_target.present?
          response_message = <<~REPLY
            *#{chosen_target.title}*
            *Status:* #{target_status_message(chosen_target)}
            *Role:* #{I18n.t("models.target.role.#{chosen_target.role}")}
            *Coach:* #{chosen_target.faculty.name}
            *Description:* #{ActionView::Base.full_sanitizer.sanitize chosen_target.description}
          REPLY

          response_message += optional_target_data if optional_target_data.present?

          response.reply_privately response_message
        else
          reply_with_choice_error
        end
      end

      def reply_with_choice_error
        response.reply_privately I18n.t('libs.lita.handlers.targets.choice_error', choices: (1..targets.count).to_a.join(', '))
      end

      def optional_target_data
        return @optional_target_data if @optional_target_data.present?

        optional = []

        add_optional_completion_instructions(optional)
        add_optional_resource_url(optional)
        add_optional_rubric(optional)

        @optional_target_data = (optional.join("\n") + "\n") if optional.present?
      end

      def add_optional_completion_instructions(optional)
        optional << "*Completion Instructions:* #{chosen_target.completion_instructions}" if chosen_target.completion_instructions.present?
      end

      def add_optional_resource_url(optional)
        if chosen_target.resource_url.present?
          shortened_url = ShortenedUrls::ShortenService.new(chosen_target.resource_url).shortened_url
          url_with_host = "https://sv.co/r/#{shortened_url.unique_key}"
          optional << "*Linked Resource:* <#{url_with_host}|#{url_with_host}>"
        end
      end

      def add_optional_rubric(optional)
        if chosen_target.rubric.present?
          shortened_url = ShortenedUrls::ShortenService.new(chosen_target.rubric_url, expires_at: 10.minutes.from_now).shortened_url
          url_with_host = "https://sv.co/r/#{shortened_url.unique_key}"
          optional << "*Rubric:* <#{url_with_host}|#{chosen_target.rubric_filename}> _(link expires in 10 minutes)_"
        end
      end

      def reply_with_targets_info
        targets_info = targets.map.with_index do |target, index|
          short_target_message(target, index)
        end.join "\n"

        response.reply_privately <<~REPLY
          #{targets_info}
          #{I18n.t('libs.lita.handlers.targets.more_info')}
        REPLY
      end

      def short_target_message(target, index)
        "*#{index + 1}.* #{target.title} _(#{target_status_message(target)})_"
      end

      # TODO: Use Targets::StatusService to get target status for founder.
      def target_status_message(_target)
        raise 'Not yet implemented'
      end

      def chosen_target
        target_number.positive? ? targets[target_number - 1] : nil
      end

      def targets
        @targets ||= begin
          (founder.targets + startup.targets).sort_by(&:created_at).reverse
        end[0..4]
      end

      def founder
        @founder ||= ::Founder.find_by(slack_username: slack_username)
      end

      def slack_username
        @slack_username ||= response.message.source.user.metadata['mention_name']
      end
    end

    # TODO: Disabling till targets fixed
    # Lita.register_handler(Targets)
  end
end
