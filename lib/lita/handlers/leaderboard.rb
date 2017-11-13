module Lita
  module Handlers
    class Leaderboard < Handler
      route(
        /\Aleaderboard\s*\?*\s*(\d*)\s*\?*\z/i,
        :leaderboard,
        command: true,
        help: {
          'leaderboard' => I18n.t('libs.lita.handlers.leaderboard.help')
        }
      )

      def leaderboard(response)
        ActiveRecord::Base.connection_pool.with_connection do
          response.reply leaderboard_response
          Ahoy::Tracker.new.track Visit::EVENT_VOCALIST_COMMAND, command: Visit::VOCALIST_COMMAND_LEADERBOARD
        end
      end

      # construct the consolidated leaderboard response for all levels
      def leaderboard_response
        if Startups::LeaderboardService.pending?
          return 'The leaderboard for last week is being generated. Please try again after a minute.'
        end

        response_title = "*<#{leaderboard_url}|Leaderboards> - #{start_date} to #{end_date}:*\n"
        leaderboard_response = ''

        levels_for_leaderboard.each do |level|
          leaderboard = Startups::LeaderboardService.new(level).leaderboard_with_change_in_rank

          leaderboard_response += if leaderboard.none? { |_s, _r, points, _c| points.positive? }
            "All startups in *Level #{level.number}* were inactive during this period.\n\n"
          else
            "\n*Level #{level.number}:*\n" + leaderboard_message_for_active_level(leaderboard) + "\n"
          end
        end

        (response_title + leaderboard_response).strip
      end

      def add_leaderboard_rows(leaderboard)
        inactive_startups = 0
        response = ''
        leaderboard.each do |startup, rank, points, change_in_rank|
          if points.zero?
            inactive_startups += 1
          else
            response += leaderboard_line(startup, rank, change_in_rank)
          end
        end

        [inactive_startups, response]
      end

      # Build the heading of the response.
      def leaderboard_heading(level)
        title = "Leaderboard for Level #{level.number}"

        "*<#{leaderboard_url}|#{title}> - #{start_date} to #{end_date}:*\n"
      end

      # Return one line in the rank list
      def leaderboard_line(startup, rank, change_in_rank)
        indicator = if change_in_rank.negative?
          ':rank_down:'
        elsif change_in_rank.positive?
          ':rank_up:'
        else
          ':rank_nochange:'
        end

        signed_change_in_rank = if change_in_rank.zero?
          '---'
        else
          format('%+d', change_in_rank).rjust(3)
        end

        "*#{format('%02d', rank)}.* #{indicator}`#{signed_change_in_rank}` - <#{Rails.application.routes.url_helpers.timeline_url(startup.id, startup.slug)}|#{startup.product_name}>\n"
      end

      def levels_for_leaderboard
        Level.where('number > ?', 0).order('number ASC')
      end

      def start_date
        DatesService.last_week_start_date.strftime('%B %-d')
      end

      def end_date
        DatesService.last_week_end_date.strftime('%B %-d')
      end

      def leaderboard_url
        Rails.application.routes.url_helpers.about_leaderboard_url
      end

      def inactive_startup_message(inactive_startups)
        "There #{'is'.pluralize(inactive_startups)} #{inactive_startups} #{'startup'.pluralize(inactive_startups)} in this level which #{'was'.pluralize(inactive_startups)} inactive during this period.\n"
      end

      def leaderboard_message_for_active_level(leaderboard)
        # Add rows to the leaderboard.
        inactive_startups, response = add_leaderboard_rows(leaderboard)

        # Add number of inactive startups, if any.
        if inactive_startups.positive?
          response += inactive_startup_message(inactive_startups)
        end
        response
      end
    end

    Lita.register_handler(Leaderboard)
  end
end
