class DatesService
  class << self
    # Start date(time) for 'last' week.
    def last_week_start_date
      week_start(last_week)
    end

    # End date(time) for 'last' week.
    def last_week_end_date
      week_end(last_week)
    end

    # Weeks start at Monday 6 PM IST.
    def week_start(time)
      time.beginning_of_week.in_time_zone('Asia/Calcutta') + 18.hours
    end

    # Weeks end at Monday 5:59:59 PM IST.
    def week_end(time)
      time.end_of_week.in_time_zone('Asia/Calcutta') + 18.hours
    end

    private

    def last_week
      if monday? && before_evening?
        8.days.ago
      else
        7.days.ago
      end
    end

    def monday?
      Time.zone.now.wday == 1
    end

    def before_evening?
      Time.zone.now.hour < 18
    end
  end
end
