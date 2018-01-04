module Lita
  module Handlers
    class ChangeLog < Handler
      route(/\Achangelog\s*\?*\s*\z/i, :changelog, command: true, help: { 'changelog ?' => I18n.t('libs.lita.handlers.changelog.help') })

      def changelog(response)
        ActiveRecord::Base.connection_pool.with_connection do
          response.reply latest_changelog
          Ahoy::Tracker.new.track Visit::EVENT_VOCALIST_COMMAND, command: Visit::VOCALIST_COMMAND_CHANGELOG
        end
      end

      private

      def latest_changelog
        salutation = "*Here are the latest changes on the SV.CO platform. Visit sv.co/changelog for more.*\n\n"
        salutation + latest_changes
      end

      def latest_release
        @latest_release ||= Changelog::ChangesService.new(Time.now.year, false).releases[0]
      end

      def latest_changes
        compiled_changes = ''

        latest_release[:categories].each do |category, changes|
          compiled_changes += "*#{category}*\n\n"

          changes.each do |change|
            compiled_changes += "> #{change[:title]}\n"
          end

          compiled_changes += "\n"
        end

        compiled_changes
      end
    end

    Lita.register_handler(ChangeLog)
  end
end
