module Schools
  class CalendarEventsController < SchoolsController
    layout 'school'

    # GET /school/courses/:course_id/calendar_events/new
    def new
      @course = current_school.courses.find(params[:course_id])
      @event = CalendarEvent.new
      authorize(@event, policy_class: Schools::CalendarEventPolicy)
    end

    # GET /school/courses/:course_id/calendar_events/:id/show
    def show
      @course = current_school.courses.find(params[:course_id])
      @event = @course.calendar_events.find(params[:id])
      authorize(@event, policy_class: Schools::CalendarEventPolicy)
    end

    # GET /school/courses/:course_id/calendar_events/:id/edit
    def edit
      @course = current_school.courses.find(params[:course_id])
      @event = @course.calendar_events.find(params[:id])
      authorize(@event, policy_class: Schools::CalendarEventPolicy)
    end

    def month_data; end
  end
end
