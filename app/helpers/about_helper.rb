module AboutHelper
  def startups_for_leaderboard
    startups_by_points = Startup.where(batch: 1)
      .joins(:karma_points)
      .where('karma_points.created_at > ?', leaderboard_date)
      .group(:startup_id)
      .sum(:points)
      .sort_by { |startup_id, points| points }.reverse

    last_points = nil
    last_rank = nil

    startups_by_points.each_with_index.map do |startup_points, index|
      startup_id, points = startup_points

      if last_points == points
        rank = last_rank
      else
        rank = index + 1
        last_rank = rank
      end

      last_points = points

      [startup_id, rank]
    end
  end

  def unranked_startups
    Startup.approved.where(batch: 1)
      .where.not(
      id: Startup.where(batch: 1)
        .joins(:karma_points)
        .where('karma_points.created_at > ?', leaderboard_date)
        .pluck(:startup_id).uniq
    )
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
