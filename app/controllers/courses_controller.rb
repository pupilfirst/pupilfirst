class CoursesController < ApplicationController
  include RecaptchaVerifiable
  include DiscordAccountRequirable

  before_action :authenticate_user!,
                except: %i[show apply process_application curriculum]

  before_action :preview_or_authenticate, only: %i[curriculum]
  before_action :require_discord_account, only: %i[curriculum report]

  # GET /courses/:id/curriculum
  def curriculum
    @presenter = Courses::CurriculumPresenter.new(view_context, @course)
    render layout: "student_course"
  end

  # GET /courses/:id/leaderboard?weeks_before=
  def leaderboard
    @course = authorize(find_course)
    @on = params[:on]
    render layout: "student_course"
  end

  # GET /courses/:id/apply
  def apply
    @course = authorize(find_course)
    @show_checkbox_recaptcha = params[:visible_recaptcha].present?

    save_tag
  end

  # POST /courses/:id/apply
  def process_application
    @course = authorize(find_course)

    form = Courses::EnrollmentForm.new(@course)

    recaptcha_success =
      recaptcha_success?(@form, action: "public_course_enrollment")

    unless recaptcha_success
      redirect_to apply_course_path(params[:id], visible_recaptcha: 1)
      return
    end

    if form.validate(params)
      form.create_applicant(session)

      flash[:success] = t(".sent_mail")

      redirect_to root_path
    else
      flash[:error] = t(
        ".errors",
        form_errors: form.errors.full_messages.join(", ")
      )

      redirect_to apply_course_path(params[:id], visible_recaptcha: 1)
    end
  end

  # GET /courses/:id/(:slug)
  def show
    @course = authorize(find_course)
    render layout: "student"
  end

  # GET /courses/:id/review
  def review
    @course = authorize(find_course)
    render html: "", layout: "app_router"
  end

  # GET /courses/:id/cohorts
  def cohorts
    @course = authorize(find_course)
    render layout: "student_course"
  end

  # GET /courses/:id/report
  def report
    @course = authorize(find_course)
    @presenter = Courses::ReportPresenter.new(view_context, @course, student)
    render layout: "student_course"
  end

  # GET /courses/:id/calendar
  def calendar
    @course = authorize(find_course)
    @presenter = Courses::CalendarsPresenter.new(view_context, @course, params)
    render layout: "student_course"
  end

  def calendar_month_data
    @course = authorize(find_course)
    @presenter = Courses::CalendarsPresenter.new(view_context, @course, params)
    render json: @presenter.month_data
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end

  def preview_or_authenticate
    course = find_course

    authenticate_user! unless course.public_preview?

    @course = authorize(course)
  end

  def student
    @student ||=
      @course.students.not_dropped_out.find_by(user_id: current_user.id)
  end

  def find_course
    policy_scope(Course).find(params[:id])
  end

  def save_tag
    return if params[:tag].blank?

    if params[:tag].in?(current_school.student_tag_list)
      session[:applicant_tag] = params[:tag]
    end
  end
end
