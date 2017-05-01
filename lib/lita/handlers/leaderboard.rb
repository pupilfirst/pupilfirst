module Lita
  module Handlers
    class Leaderboard < Handler
      route(
        /\Aleaderboard\s*\?*\s*(\d*)\s*\?*\z/i,
        :leaderboard,
        command: true,
        help: {
          'leaderboard [LEVEL NUMBER]' => I18n.t('slack.help.leaderboard')
        }
      )

      def leaderboard(response)
        ActiveRecord::Base.connection_pool.with_connection do
          # check if a particular batch was requested by parsing the regex matches
          @level = response.match_data[1].present? ? Level.find_by(number: response.match_data[1].to_i) : nil
          @level = nil if @level&.number&.zero?

          if @level.nil?
            send_level_required_message(response)
          else
            response.reply leaderboard_response_message
          end
        end
      end

      # send a relevant please wait method
      def send_level_required_message(response)
        response.reply('Please supply the level number for which leaderboard is required! Try `leaderboard [1-4]`')
      end

      # construct the leaderboard response to be send
      def leaderboard_response_message
        # Load the leaderboard.
        leaderboard = Startups::LeaderboardService.new(@level).leaderboard_with_change_in_rank

        # Return simple message if there are no active startups in this leaderboard.
        if leaderboard.none? { |_s, _r, points, _c| points.positive? }
          return 'All startups at this level were inactive during this period.'
        end

        # Add rows to the leaderboard.
        inactive_startups, response = add_leaderboard_rows(leaderboard, leaderboard_heading)

        # Add number of inactive startups, if any.
        if inactive_startups.positive?
          response += "\nThere #{'is'.pluralize(inactive_startups)} #{inactive_startups} #{'startup'.pluralize(inactive_startups)} in this level which #{'was'.pluralize(inactive_startups)} inactive during this period."
        end

        response
      end

      def add_leaderboard_rows(leaderboard, response)
        inactive_startups = 0

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
      def leaderboard_heading
        leaderboard_url = Rails.application.routes.url_helpers.about_leaderboard_url
        title = "Leaderboard for Level #{@level.number}"
        start_date = DatesService.last_week_start_date.strftime('%B %-d')
        end_date = DatesService.last_week_end_date.strftime('%B %-d')

        "*<#{leaderboard_url}|#{title}> - #{start_date} to #{end_date}:*\n"
      end

      # Return one l
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

        "*#{format('%02d', rank)}.* #{indicator}`#{signed_change_in_rank}` - <#{Rails.application.routes.url_helpers.startup_url(startup)}|#{startup.product_name}>\n"
      end
    end

    Lita.register_handler(Leaderboard)
  end
end
