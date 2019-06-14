class CoursesController < ApplicationController
  layout 'student_course', except: :leaderboard

  # GET /courses/:id/(:slug)
  def show
    @course = authorize(Course.find(params[:id]))
    @presenter = Courses::ShowPresenter.new(view_context, @course)
  end

  # GET /courses/:id/leaderboard?weeks_before=
  def leaderboard
    @course = authorize(Course.find(params[:id]))
  end
end
