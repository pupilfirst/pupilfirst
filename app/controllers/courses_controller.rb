class CoursesController < ApplicationController
  before_action :authenticate_user!, except: %i[show apply curriculum]
  before_action :preview_or_authenticate, only: %i[curriculum]

  # GET /courses/:id/curriculum
  def curriculum
    @presenter = Courses::CurriculumPresenter.new(view_context, @course)
    render layout: 'student_course'
  end

  # GET /courses/:id/leaderboard?weeks_before=
  def leaderboard
    @course = find_course
    @on = params[:on]
    render layout: 'student_course'
  end

  # GET /courses/:id/apply
  def apply
    @course = find_course
    save_tag
    render layout: 'tailwind'
  end

  # GET /courses/:id/(:slug)
  def show
    @course = find_course
    render layout: 'student'
  end

  # GET /courses/:id/review
  def review
    @course = find_course
    render layout: 'student_course'
  end

  # GET /courses/:id/students
  def students
    @course = find_course
    render layout: 'student_course'
  end

  # GET /courses/:id/report
  def report
    @course = find_course
    render layout: 'student_course'
  end

  private

  def preview_or_authenticate
    @course = find_course
    authenticate_user! unless @course.public_preview?
  end

  def find_course
    authorize(policy_scope(Course).find(params[:id]))
  end

  def save_tag
    return if params[:tag].blank?

    if params[:tag].in?(current_school.founder_tag_list)
      session[:applicant_tag] = params[:tag]
    end
  end
end
