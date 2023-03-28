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
      calendar_params = params.require(:calendar).permit(:name, cohort_ids: [])

      calendar_params[:cohort_ids] =
        @course.cohorts.where(id: calendar_params[:cohort_ids]).pluck(:id)

      @course.calendars.create!(calendar_params)

      authorize(@calendar, policy_class: Schools::CalendarEventPolicy)

      flash[:success] = I18n.t('calendars.create.success')
      redirect_to school_course_calendar_events_path(@course)
    end

    def edit
      @course = current_school.courses.find(params[:course_id])
      @calendar = @course.calendars.find(params[:id])
      authorize(@calendar, policy_class: Schools::CalendarEventPolicy)
    end

    # POST /school/calendars/:id
    def update
      @calendar = current_school.calendars.find(params[:id])
      @course = @calendar.course
      calendar_params = params.require(:calendar).permit(:name, cohort_ids: [])
      calendar_params[:cohort_ids] =
        @course.cohorts.where(id: calendar_params[:cohort_ids]).pluck(:id)
      @calendar.update!(calendar_params)

      authorize(@calendar, policy_class: Schools::CalendarEventPolicy)

      flash[:success] = I18n.t('calendars.update.success')
      redirect_to school_course_calendar_events_path(@course)
    end
  end
end
