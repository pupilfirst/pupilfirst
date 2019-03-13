class CoursesController < ApplicationController
  # GET /courses/:id/leaderboard?weeks_before=
  def leaderboard
    @course = authorize(Course.find(params[:id]))

    weeks_before = params[:weeks_before].to_i
    raise_not_found unless weeks_before.between?(0, 12)

    @leaderboard_at = Time.zone.now - weeks_before.weeks
  end
end
