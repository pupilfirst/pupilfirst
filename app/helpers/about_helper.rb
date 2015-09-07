module AboutHelper
  def startups_for_leaderboard
    Startup.joins(:karma_points)
      .where('karma_points.created_at > ?', leaderboard_date)
      .group(:startup_id)
      .sum(:points)
      .sort_by {|startup_id, points| points}.reverse
  end

  def leaderboard_date
    if monday? && before_evening?
      Date.yesterday.beginning_of_week
    else
      Date.today.beginning_of_week
    end
  end

  private

  def monday?
    Date.today.in_time_zone('Asia/Calcutta').wday == 1
  end

  def before_evening?
    Time.now.in_time_zone('Asia/Calcutta').hour < 20
  end
end
