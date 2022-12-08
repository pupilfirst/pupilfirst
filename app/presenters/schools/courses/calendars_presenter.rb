module Schools
  module Courses
    class CalendarsPresenter < ApplicationPresenter
      def initialize(view_context, course, params)
        @course = course
        @date = params[:date] ? Date.parse(params[:date]) : Date.today

        super(view_context)
      end

      def events_for_day
        @course.calendar_events.where(start_time: (@date).all_day)
      end

      def selected_date
        @date.strftime('%d-%B-%Y')
      end

      def upcoming_events
        @course
          .calendar_events
          .where(
            start_time: @date.end_of_day,
            end_time: @date.end_of_day + 1.month
          )
          .limit(10)
      end
    end
  end
end
