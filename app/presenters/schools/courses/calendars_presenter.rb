module Schools
  module Courses
    class CalendarsPresenter < ApplicationPresenter
      def initialize(view_context, course, params)
        @course = course
        @date = params[:date] ? Date.parse(params[:date]) : Date.today

        super(view_context)
      end

      def props
        { events: tag_details, upcoming_events: course_details }
      end

      private

      def events
        @course.calendar_events.where(start_time: @date.all_day)
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
