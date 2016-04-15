module Lita
  module Handlers
    class Targets < Handler
      route(
        /^targets\??\sinfo\s(\d)$|^targets\??$/,
        :targets_handler,
        command: true,
        help: {
          'targets' => I18n.t('slack.help.targets'),
          'targets info [NUMBER]' => I18n.t('slack.help.targets_info')
        }
      )

      attr_reader :response

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
            response.reply_privately I18n.t('slack.handlers.targets.unknown_username', slack_username: slack_username)
          end
        end
      end

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
            *Role:* #{I18n.t("role.#{chosen_target.role}")}
            *Assigner:* #{chosen_target.assigner.name}
            *Description:* #{ActionView::Base.full_sanitizer.sanitize chosen_target.description}
          REPLY

          response_message += optional_target_data if optional_target_data.present?

          response.reply_privately response_message
        else
          reply_with_choice_error
        end
      end

      def reply_with_choice_error
        response.reply_privately I18n.t('slack.handlers.targets.choice_error', choices: (1..targets.count).to_a.join(', '))
      end

      def optional_target_data
        return @optional_target_data if @optional_target_data.present?

        optional = []

        optional << "*Completion Instructions:* #{chosen_target.completion_instructions}" if chosen_target.completion_instructions.present?

        if chosen_target.resource_url.present?
          shortened_url = Shortener::ShortenedUrl.generate chosen_target.resource_url
          url_with_host = "https://sv.co/#{shortened_url.unique_key}"
          optional << "*Linked Resource:* <#{url_with_host}|#{url_with_host}>"
        end

        if chosen_target.rubric.present?
          shortened_url = Shortener::ShortenedUrl.generate(chosen_target.rubric_url, expires_at: 10.minutes.from_now)
          url_with_host = "https://sv.co/#{shortened_url.unique_key}"
          optional << "*Rubric:* <#{url_with_host}|#{chosen_target.rubric_filename}> _(link expires in 10 minutes)_"
        end

        @optional_target_data = (optional.join("\n") + "\n") if optional.present?
      end

      def reply_with_targets_info
        targets_info = targets.map.with_index do |target, index|
          short_target_message(target, index)
        end.join "\n"

        response.reply_privately <<~REPLY
          #{targets_info}
          #{I18n.t('slack.handlers.targets.more_info')}
        REPLY
      end

      def short_target_message(target, index)
        "*#{index + 1}.* #{target.title} _(#{target_status_message(target)})_"
      end

      def target_status_message(target)
        if target.expired?
          'Expired'
        elsif target.done?
          'Done'
        else
          "Pending - Due on #{target.due_date.strftime '%A, %b %d'}"
        end
      end

      def chosen_target
        target_number > 0 ? targets[target_number - 1] : nil
      end

      def targets
        @targets ||= begin
          (founder.targets + startup.targets).sort_by(&:created_at).reverse
        end[0..4]
      end

      def startup
        founder.startup
      end

      def founder
        @founder ||= ::Founder.find_by(slack_username: slack_username)
      end

      def slack_username
        @slack_username ||= response.message.source.user.metadata['mention_name']
      end
    end

    Lita.register_handler(Targets)
  end
end
