class TopicsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  def show
    @topic = authorize(Topic.live.find(params[:id]))
    Topics::IncrementViewsService.new(@topic).execute(current_user)
  end
end
