class ConnectRequestController < ApplicationController
  # GET /connect_request/:id/feedback/from_team/:token
  def feedback_from_team
    params[:rating]
  end

  # GET /connect_request/:id/feedback/from_faculty/:token
  def feedback_from_faculty
    params[:rating]
  end
end
