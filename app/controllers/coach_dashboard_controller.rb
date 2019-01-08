class CoachDashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @course = authorize(Course.find(params[:course_id]), policy_class: CoachDashboardPolicy)
    @skip_container = true
  end
end
