class DatesService
  class << self
    # Start date(time) for 'last' week.
    def last_week_start_date
      week_start(1.week.ago)
    end

    # End date(time) for 'last' week.
    def last_week_end_date
      week_end(1.week.ago)
    end

    # Weeks start at Monday 6 PM IST.
    def week_start(time)
      week_beginning(time).in_time_zone('Asia/Calcutta') + 18.hours
    end

    # Weeks end at Monday 5:59:59 PM IST.
    def week_end(time)
      week_beginning(time).end_of_week.in_time_zone('Asia/Calcutta') + 18.hours
    end

    private

    def week_beginning(time)
      if monday?(time) && before_evening?(time)
        (time - 1.day)
      else
        time
      end.beginning_of_week
    end

    def monday?(time = Time.zone.now)
      time.wday == 1
    end

    def before_evening?(time = Time.zone.now)
      time.hour < 18
    end
  end
end
