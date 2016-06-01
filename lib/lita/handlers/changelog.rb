module Lita
  module Handlers
    class ChangeLog < Handler
      route(/\Achangelog\s*\?*\s*\z/i, :changelog, command: true, help: { 'changelog ?' => I18n.t('slack.help.changelog') })

      def changelog(response)
        response.reply latest_change_log
      end

      def latest_change_log
        load_file
        extract_latest_log
        format_for_slack
      end

      def load_file
        @changelog_file = File.read(File.absolute_path(Rails.root.join('CHANGELOG.md')))
      end

      def extract_latest_log
        @latest_log = @changelog_file.strip.split(/^##\s/)[1]
      end

      def format_for_slack
        salutation = "*Here is a snippet of the latest changes on the SV.CO Platform:*\n"

        # replace '###' with slack-friendly '>'
        @latest_log.gsub!(/###/, '> ')

        salutation + @latest_log
      end
    end

    Lita.register_handler(ChangeLog)
  end
end
