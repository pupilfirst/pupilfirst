module Schools
  class CalendarEventsController < SchoolsController
    layout 'school'

    # GET /school/courses/:course_id/calendar_events/new
    def new
      @course = current_school.courses.find(params[:course_id])
      @event = CalendarEvent.new
      @form = CalendarEvents::CreateOrUpdateForm.new
      authorize(@event, policy_class: Schools::CalendarEventPolicy)
    end

    # POST /school/courses/:course_id/calendar_events/
    def create
      @course = current_school.courses.find(params[:course_id])
      authorize(CalendarEvent.new, policy_class: Schools::CalendarEventPolicy)

      @form =
        CalendarEvents::CreateOrUpdateForm.new(calendar_event_params(params))

      @form.validate

      if @form.valid?
        @form.save
        flash[:success] = 'Event created successfully'
        redirect_to school_course_calendar_events_path(@course)
      else
        flash.now[:error] = @form.errors.map { |e| e.full_message }
        @event = CalendarEvent.new
        render :new
      end
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

    def update
      @course = current_school.courses.find(params[:course_id])
      @event = @course.calendar_events.find(params[:id])
      authorize(@event, policy_class: Schools::CalendarEventPolicy)

      @form =
        CalendarEvents::CreateOrUpdateForm.new(
          calendar_event_params(params).merge!(id: @event.id)
        )

      @form.validate

      if @form.valid?
        @form.save
        flash[:success] = 'Event updated successfully'
        redirect_to school_course_calendar_events_path(@course)
      else
        flash.now[:error] = @form.errors.map { |e| e.full_message }
        render :edit
      end
    end

    def destroy
      @course = current_school.courses.find(params[:course_id])
      @event = @course.calendar_events.find(params[:id])
      authorize(@event, policy_class: Schools::CalendarEventPolicy)

      if @event.present?
        @event.destroy
        flash[:success] = 'Event deleted successfully'
        redirect_to school_course_calendar_events_path(@course)
      else
        flash[:error] = 'Event not found'
        redirect_to school_course_calendar_events_path(@course)
      end
    end

    private

    def calendar_event_params(params)
      params
        .require(:calendar_event)
        .permit(
          :title,
          :description,
          :calendar_id,
          :color,
          :start_time,
          :link_url,
          :link_title
        )
    end
  end
end
