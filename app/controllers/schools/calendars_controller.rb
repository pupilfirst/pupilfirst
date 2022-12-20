module Schools
  class CalendarsController < SchoolsController
    layout 'school'

    # GET /school/courses/:course_id/calendars/new
    def new
      @course = current_school.courses.find(params[:course_id])
      @calendar = Calendar.new
      authorize(@calendar, policy_class: Schools::CalendarEventPolicy)
    end

    def create
      @course = current_school.courses.find(params[:course_id])

      authorize(@calendar, policy_class: Schools::CalendarEventPolicy)
    end

    def edit
      @course = current_school.courses.find(params[:course_id])
      @calendar = @course.calendars.find(params[:id])
      authorize(@calendar, policy_class: Schools::CalendarEventPolicy)
    end
  end
end
