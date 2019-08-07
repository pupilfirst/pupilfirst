class CoursesController < ApplicationController
  # GET /courses/:id/curriculum
  def curriculum
    @course = authorize(policy_scope(Course).find(params[:id]))
    @presenter = Courses::CurriculumPresenter.new(view_context, @course)
    render layout: 'student_course'
  end

  # GET /courses/:id/leaderboard?weeks_before=
  def leaderboard
    @course = authorize(policy_scope(Course).find(params[:id]))
    render layout: 'student_course'
  end

  # GET /courses/:id/apply
  def apply
    @course = authorize(policy_scope(Course).find(params[:id]))
    render layout: 'student'
  end

  # GET /courses/:id/(:slug)
  def show
    @course = authorize(policy_scope(Course).find(params[:id]))
    render layout: 'student'
  end
end
