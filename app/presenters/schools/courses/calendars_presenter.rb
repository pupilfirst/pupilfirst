module Schools
  module Courses
    class CalendarsPresenter < ApplicationPresenter
      def initialize(view_context, course, params)
        @course = course
        @date = params[:date] ? Date.parse(params[:date]) : Time.current.to_date
        @selected_calendar =
          @course.calendars&.find_by(id: params[:calendar_id])
        super(view_context)
      end

      def events_for_day
        events_scope.where(start_time: (@date).all_day)
      end

      def selected_date
        @date.strftime("%d-%B-%Y")
      end

      def events_scope
        if @selected_calendar
          @selected_calendar.calendar_events
        else
          @course.calendar_events
        end
      end

      def upcoming_events_for_month
        events_scope
          .where(start_time: @date.end_of_day..@date.end_of_month.end_of_day)
          .order(:start_time)
          .limit(10)
      end

      def selected_month
        @date.strftime("%B")
      end

      def today?
        @date == Time.current.to_date
      end

      def calendar_link(calendar)
        return if calendar.nil?
        {
          name: calendar.name,
          url:
            view.calendar_events_school_course_path(
              @course,
              calendar_id: calendar.id,
              date: selected_date
            )
        }
      end

      def calendar_link_props
        {
          links: @course.calendars.map { |calendar| calendar_link(calendar) },
          selectedLink: calendar_link(@selected_calendar),
          placeholder:
            I18n.t("schools.courses.calendar_events.select_calendar_filter")
        }
      end

      def date_picker_props
        {
          selectedDate: @date.iso8601,
          courseId: @course.id.to_s,
          selectedCalendarId: @selected_calendar&.id&.to_s,
          source: "admin"
        }.to_json
      end

      def month_data
        events_scope
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
