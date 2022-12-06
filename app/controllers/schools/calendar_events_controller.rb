module Schools
  class CalendarEventsController < SchoolsController
    layout 'school'

    # GET /school/courses/:course_id/calendar_events/new
    def new
      @course = current_school.courses.find(params[:course_id])
      @event = CalendarEvent.new
      authorize(@event, policy_class: Schools::CalendarEventPolicy)
    end

    # GET /school/courses/:course_id/calendar_events/:id
    def show
      @course = current_school.courses.find(params[:course_id])
      @event = @course.calendar_events.find(params[:id])
      authorize(
        @course.course_authors.find(params[:id]),
        policy_class: Schools::CourseAuthorPolicy
      )
      render 'schools/courses/authors'
    end
  end
end
