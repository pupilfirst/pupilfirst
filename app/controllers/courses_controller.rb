class CoursesController < ApplicationController
  layout 'student_course', only: :show
  layout 'student', only: :enroll

  # GET /courses/:id/(:slug)
  def show
    @course = authorize(Course.find(params[:id]))
    @presenter = Courses::ShowPresenter.new(view_context, @course)
  end

  # GET /courses/:id/leaderboard?weeks_before=
  def leaderboard
    @course = authorize(Course.find(params[:id]))
  end

  # GET /courses/:id/enroll
  def enroll
    @course = authorize(Course.find(params[:id]))
  end
end
