module Founders
  class ActivityTimelineService
    include Loggable

    def initialize(founder, to)
      @founder = founder
      @to = to
    end

    def activities
      all_activity = @founder.karma_points.where(created_at: time_range) +
        @founder.timeline_events.where(created_at: time_range) +
        @founder.public_slack_messages.where(created_at: time_range)

      sorted_activity = all_activity.sort_by(&:created_at)

      sorted_activity.each_with_object(blank_activity_timeline) do |activity, timeline|
        if activity.is_a? PublicSlackMessage
          add_public_slack_message_to_timeline(activity, timeline)
        elsif activity.is_a? TimelineEvent
          add_timeline_event_to_timeline(activity, timeline)
        elsif activity.is_a? KarmaPoint
          add_karma_point_to_timeline(activity, timeline)
        end
      end
    end

    def more_in_past?
      month_delta(@founder.created_at, end_date) > 6
    end

    def more_in_future?
      month_delta(end_date, Date.today).positive?
    end

    # Latest of founder creation date or 5 months ago, so that we show six months' worth of data.
    def start_date
      @start_date ||= [@founder.created_at.to_date, (end_date - 5.months)].max
    end

    def end_date
      @end_date ||= begin
        # Only attempt to parse the date if it looks like a date.
        date = if @to.present? && @to.match?(/^\d{4}-\d{2}-\d{2}$/)
          begin
            Date.parse(@to)
          rescue ArgumentError
            Date.today
          end
        else
          Date.today
        end

        # Don't allow end_date to be in the future. We don't want to show empty months.
        date = [Date.today, date].min

        # If the number of months between supplied end date and founder's creation is less than 6, and the user has been
        # around for longer than 6 months, then set the end date as six months from creation date, to ensure at least
        # six months' data is returned for such users.
        if month_delta(@founder.created_at.to_date, date) < 6 && month_delta(@founder.created_at.to_date, Date.today) > 6
          date = (@founder.created_at + 5.months).to_date
        end

        date
      end
    end

    # Returns date to be used as 'to' to view immediate past activity.
    def past_date
      start_date - 1.month
    end

    # Returns date to be used as 'to' to view immediate future activity.
    def future_date
      (end_date + 6.months).future? ? Date.today : (end_date + 6.months)
    end

    private

    def blank_activity_timeline
      start_at = start_date.beginning_of_month
      end_at = end_date.end_of_month

      first_day_of_each_month = (start_at..end_at).select { |d| d.day == 1 }

      first_day_of_each_month.each_with_object({}) do |first_day_of_month, blank_timeline|
        blank_timeline[month_label(first_day_of_month)] = {
          counts: (1..WeekOfMonth.total_weeks(first_day_of_month)).each_with_object({}) { |w, o| o[w] = 0 }
        }
      end
    end

    def time_range
      @time_range ||= begin
        start_time = start_date.in_time_zone('Asia/Calcutta').beginning_of_month
        end_time = end_date.in_time_zone('Asia/Calcutta').end_of_month
        (start_time..end_time)
      end
    end

    def month_delta(from, to)
      (to.year * 12 + to.month) - (from.year * 12 + from.month)
    end

    def add_public_slack_message_to_timeline(activity, timeline)
      month = month_label(activity.created_at)

      increment_activity_count(timeline, month, WeekOfMonth.week_of_month(activity.created_at))

      if timeline[month][:list] && timeline[month][:list].last[:type] == :public_slack_message
        timeline[month][:list].last[:count] += 1
      else
        timeline[month][:list] ||= []
        timeline[month][:list] << { type: :public_slack_message, count: 1 }
      end
    end

    def add_timeline_event_to_timeline(activity, timeline)
      month = month_label(activity.created_at)

      increment_activity_count(timeline, month, WeekOfMonth.week_of_month(activity.created_at))

      timeline[month][:list] ||= []
      timeline[month][:list] << { type: :timeline_event, timeline_event: activity }
    end

    def add_karma_point_to_timeline(activity, timeline)
      month = month_label(activity.created_at)

      increment_activity_count(timeline, month, WeekOfMonth.week_of_month(activity.created_at))

      timeline[month][:list] ||= []
      timeline[month][:list] << { type: :karma_point, karma_point: activity }
    end

    def increment_activity_count(timeline, month, week)
      timeline[month][:counts][week] ||= 0
      timeline[month][:counts][week] += 1
    end

    def month_label(time)
      if time.month == 1 || time.month == 12
        time.strftime("%b '%y")
      else
        time.strftime('%B')
      end
    end
  end
end
