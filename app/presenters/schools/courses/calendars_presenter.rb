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
    end
  end
end
