class DatesService
  # Starts on the week before last's Monday 6 PM IST.
  def self.last_week_start_date
    if monday? && before_evening?
      8.days.ago.beginning_of_week
    else
      7.days.ago.beginning_of_week
    end.in_time_zone('Asia/Calcutta') + 18.hours
  end

  # Ends on last week's Monday 6 PM IST.
  def self.last_week_end_date
    if monday? && before_evening?
      8.days.ago.end_of_week
    else
      7.days.ago.end_of_week
    end.in_time_zone('Asia/Calcutta') + 18.hours
  end

  def self.monday?
    Date.today.in_time_zone('Asia/Calcutta').wday == 1
  end

  def self.before_evening?
    Time.now.in_time_zone('Asia/Calcutta').hour < 18
  end
end
