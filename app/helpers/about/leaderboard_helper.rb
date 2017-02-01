module About
  module LeaderboardHelper
    def change_in_rank_icon(change_in_rank)
      if change_in_rank.negative?
        'fa-arrow-down leaderboard__rank-icon leaderboard__rank-icon--red'
      elsif change_in_rank.positive?
        'fa-arrow-up leaderboard__rank-icon leaderboard__rank-icon--green'
      else
        'fa-dot-circle-o leaderboard__rank-icon leaderboard__rank-icon--grey'
      end
    end
  end
end
