module About
  module LeaderboardHelper
    def change_in_rank_icon(change_in_rank)
      if change_in_rank.negative?
        'fa-caret-down leaderboard__rank-icon red-text'
      elsif change_in_rank.positive?
        'fa-caret-up leaderboard__rank-icon green-text'
      else
        'fa-circle leaderboard__rank-icon light-grey-text'
      end
    end
  end
end
