class TimelineEventFilesController < ApplicationController
  before_action :authenticate_user!

  # GET /timeline_event_files/:id/download
  def download
    timeline_event_file = authorize(TimelineEventFile.find(params[:id]))

    destination =
      Rails.application.routes.url_helpers.rails_public_blob_url(
        timeline_event_file.file
      )

    redirect_to(destination, allow_other_host: true)
  end

  # POST /timeline_event_files
  def create
    timeline_event_file = authorize(TimelineEventFile.new(file: params[:file]))
    timeline_event_file.user = current_user
    timeline_event_file.save!

    render json: { id: timeline_event_file.id.to_s }
  end
end
