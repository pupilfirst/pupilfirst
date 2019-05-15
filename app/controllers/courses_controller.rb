class CoursesController < ApplicationController
  # GET /courses/:id/(:slug)
  def show
    @course = authorize(Course.find(params[:id]))
    @presenter = Courses::ShowPresenter.new(view_context, @course)
    render layout: 'student_course'
  end

  # GET /courses/:id/leaderboard?weeks_before=
  def leaderboard
    @course = authorize(Course.find(params[:id]))
  end
end
