# This class is a replacement for the gem 'week_of_month', which had to be removed since it messed with ActiveSupport's
# implementation of some basic datetime methods.
class WeekOfMonth
  # Returns the week 'number' (of month), for any given date or time.
  def self.week_of_month(date_or_time)
    number_for_supplied_date = date_or_time.strftime('%U').to_i
    number_for_beginning_of_month = date_or_time.beginning_of_month.strftime('%U').to_i

    # Add one to the difference to avoid returning 0.
    (number_for_supplied_date - number_for_beginning_of_month) + 1
  end

  # Returns the total number of weeks, for any given date or time (in that month).
  def self.total_weeks(date_or_time)
    number_for_beginning_of_month = date_or_time.beginning_of_month.strftime('%U').to_i
    number_for_end_of_month = date_or_time.end_of_month.strftime('%U').to_i

    # Add one to the difference.
    (number_for_end_of_month - number_for_beginning_of_month) + 1
  end
end
