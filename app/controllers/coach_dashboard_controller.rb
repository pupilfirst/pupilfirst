class CoachDashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # authorize %i[coaches dashboard]
    @course = Course.find(params[:course_id])
    @skip_container = true
  end
end
