class TopicsController < ApplicationController
  before_action :authenticate_user!
  layout 'student'

  def show
    @topic = authorize(Topic.live.find(params[:id]))
  end
end
