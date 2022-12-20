module Schools
  module Courses
    class CalendarsPresenter < ApplicationPresenter
      def initialize(view_context, course, params)
        @course = course
        @date = params[:date] ? Date.parse(params[:date]) : Time.current.to_date

        super(view_context)
      end

      def events_for_day
        @course.calendar_events.where(start_time: (@date).all_day)
      end

      def selected_date
        @date.strftime('%d-%B-%Y')
      end

      def upcoming_events_for_month
        @course
          .calendar_events
          .where(start_time: @date.end_of_day..@date.end_of_month.end_of_day)
          .order(:start_time)
          .limit(10)
      end

      def selected_month
        @date.strftime('%B')
      end

      def today?
        @date == Time.current.to_date
      end

      def date_picker_props
        { selectedDate: @date.iso8601, courseId: @course.id.to_s }.to_json
      end

      def month_data
        applicable_events = @course.calendar_events
        applicable_events
          .group_by_day(range: @date.all_month, series: true) do |event|
            event.start_time
          end
          .each_with_object({}) do |(day, events), hash|
            hash[day.iso8601] = events.map(&:color).uniq.first(3)
          end
      end
    end
  end
end
