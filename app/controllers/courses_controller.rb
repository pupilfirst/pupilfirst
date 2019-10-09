class CoursesController < ApplicationController
  before_action :authenticate_user!, except: %i[show apply]

  # GET /courses/:id/curriculum
  def curriculum
    @course = find_course
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
    render layout: 'student'
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

  private

  def find_course
    authorize(policy_scope(Course).find(params[:id]))
  end
end
