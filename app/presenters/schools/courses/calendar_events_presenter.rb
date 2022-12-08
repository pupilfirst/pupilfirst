module Schools
  module Courses
    class CalendarEventsPresenter < ApplicationPresenter
      def initialize(view_context, course, params)
        @course = course
        @params = params
        super(view_context)
      end

      def month_data
        @course.calendar_events.where(start_time: (@date).all_day)
      end
    end
  end
end
