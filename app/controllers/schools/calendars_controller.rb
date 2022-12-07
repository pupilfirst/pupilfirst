module Schools
  class CalendarsController < SchoolsController
    layout 'school'

    # GET /school/courses/:course_id/calendars/new
    def new
      @course = current_school.courses.find(params[:course_id])
      @calendar = Calendar.new
      authorize(@calendar, policy_class: Schools::CalendarEventPolicy)
    end
  end
end
