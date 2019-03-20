class CoursesController < ApplicationController
  # GET /courses/:id/leaderboard?weeks_before=
  def leaderboard
    @course = authorize(Course.find(params[:id]))
  end
end
