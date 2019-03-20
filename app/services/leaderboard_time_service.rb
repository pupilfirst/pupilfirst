class LeaderboardTimeService
  def initialize(week_delta = 0)
    @week_delta = week_delta
  end

  def week_start
    @week_start ||= adjusted_time(1)
  end

  def week_end
    @week_end ||= adjusted_time(0)
  end

  def last_week_start
    @last_week_start ||= adjusted_time(2)
  end

  def last_week_end
    week_start
  end

  private

  def leaderboard_at
    @leaderboard_at ||= Time.zone.now - @week_delta.weeks
  end

  def adjusted_time(week_minus)
    week_beginning(leaderboard_at - week_minus.weeks).in_time_zone('Asia/Calcutta') + 12.hours
  end

  def week_beginning(time)
    if monday?(time) && before_noon?(time)
      (time - 1.day)
    else
      time
    end.beginning_of_week
  end

  def monday?(time = Time.zone.now)
    time.wday == 1
  end

  def before_noon?(time)
    time.hour < 12
  end
end
