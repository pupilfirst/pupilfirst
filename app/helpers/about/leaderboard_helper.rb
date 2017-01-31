module About
  module LeaderboardHelper
    def change_in_rank_icon(change_in_rank)
      if change_in_rank.negative?
        'fa-chevron-down leaderboard__rank-icon red-text'
      elsif change_in_rank.positive?
        'fa-chevron-up leaderboard__rank-icon green-text'
      else
        'fa-arrows-h leaderboard__rank-icon grey-text'
      end
    end
  end
end
