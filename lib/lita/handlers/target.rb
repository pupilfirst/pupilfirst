module Lita
  module Handlers
    class Target < Handler
      route(
        /^targets\??\sinfo\s(\d)|targets\??$/,
        :targets_handler,
        command: true,
        help: {
          'targets' => 'Get a list of targets assigned to you and your team.',
          'targets info [NUMBER]' => 'Get detailed information about a target from list.'
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
            response.reply <<~REPLY
              I'm sorry, but your slack mention name `@#{slack_username}` isn't known to me.
              Please update your slack mention name on your SV.CO profile, and try asking me again.
            REPLY
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
        response.reply <<~REPLY
          I'm supposed to send you all info I have about target no. #{target_number},
          but I don't know how to yet. Sorry. :cry:
        REPLY
      end

      def reply_with_targets_info
        targets_info = targets.map.with_index do |target, index|
          short_target_message(target, index)
        end.join "\n"

        response.reply <<~REPLY
          #{targets_info}
          Reply with `targets info [NUMBER]` for more information about a target.
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
          "Pending. Due on #{target.due_date.strftime '%A, %b %d'}"
        end
      end

      def chosen_target
        targets[target_number - 1]
      end

      def targets
        @targets ||= begin
          (founder.targets + startup.targets).sort_by { |target| target.created_at }.reverse
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

    Lita.register_handler(Target)
  end
end
