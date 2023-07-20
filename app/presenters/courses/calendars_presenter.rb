module Courses
  class CalendarsPresenter < ApplicationPresenter
    def initialize(view_context, course, params)
      @course = course
      @date = params[:date] ? Date.parse(params[:date]) : Time.current.to_date

      super(view_context)
    end

    def events_for_day
      events_scope.where(start_time: @date.all_day)
    end

    def selected_date
      @date.strftime('%d-%B-%Y')
    end

    def events_scope
      return CalendarEvent.none unless @course.calendars.exists?

      cohort_calendars = @course.calendars.joins(:cohorts)
      course_calendars = @course.calendars.where.not(id: cohort_calendars)

      CalendarEvent.where(
        calendar:
          course_calendars +
            (applicable_cohort_calendars(cohort_calendars) || [])
      )
    end

    def upcoming_events_for_month
      events_scope
        .where(start_time: @date.end_of_day..@date.end_of_month.end_of_day)
        .order(:start_time)
        .limit(30)
    end

    def selected_month
      @date.strftime('%B')
    end

    def today?
      @date == Time.current.to_date
    end

    def date_picker_props
      {
        selectedDate: @date.iso8601,
        courseId: @course.id.to_s,
        source: 'student'
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

    private

    def applicable_cohort_calendars(cohort_calendars)
      return if cohort_calendars.blank?

      applicable_cohorts = []

      if current_user.students.present?
        applicable_cohorts <<
          current_user
            .students
            .joins(:cohort)
            .where(cohorts: { course_id: @course })
            .pluck(:cohort_id)
      end

      if current_user.faculty.present?
        applicable_cohorts << current_user.faculty.cohorts.pluck(:id)
      end

      cohort_calendars.where(cohorts: { id: applicable_cohorts.flatten })
    end
  end
end
