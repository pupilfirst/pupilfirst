module AboutHelper
  def startups_for_leaderboard_of_batch(batch)
    startups_by_points = Startup.not_dropped_out.where(batch_number: batch)
      .joins(:karma_points)
      .where('karma_points.created_at > ?', leaderboard_start_date)
      .where('karma_points.created_at < ?', leaderboard_end_date)
      .group(:startup_id)
      .sum(:points)
      .sort_by { |_startup_id, points| points }.reverse

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

  def startups_without_karma_and_rank_for_batch(batch)
    ranked_startup_ids = Startup.not_dropped_out.where(batch_number: batch)
      .joins(:karma_points)
      .where('karma_points.created_at > ?', leaderboard_start_date)
      .where('karma_points.created_at < ?', leaderboard_end_date)
      .pluck(:startup_id).uniq

    unranked_startups = Startup.not_dropped_out.where(batch_number: batch)
      .where.not(id: ranked_startup_ids)

    [unranked_startups, ranked_startup_ids.count + 1]
  end

  # Starts on the week before last's Monday 6 PM IST.
  def leaderboard_start_date
    if monday? && before_evening?
      8.days.ago.beginning_of_week
    else
      7.days.ago.beginning_of_week
    end.in_time_zone('Asia/Calcutta') + 18.hours
  end

  # Ends on last week's Monday 6 PM IST.
  def leaderboard_end_date
    if monday? && before_evening?
      8.days.ago.end_of_week
    else
      7.days.ago.end_of_week
    end.in_time_zone('Asia/Calcutta') + 18.hours
  end

  private

  def monday?
    Date.today.in_time_zone('Asia/Calcutta').wday == 1
  end

  def before_evening?
    Time.now.in_time_zone('Asia/Calcutta').hour < 18
  end
end
