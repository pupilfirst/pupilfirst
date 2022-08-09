class FoundersController < ApplicationController
  # GET /students/:id/report
  def report
    authorize(Founder.find(params[:id]))
    render html: '', layout: 'app_router'
  end
end
