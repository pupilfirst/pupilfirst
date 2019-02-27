class TimelineEventFilesController < ApplicationController
  # GET /timeline_event_files/:id/download
  def download
    timeline_event_file = authorize(TimelineEventFile.find(params[:id]))
    destination = Rails.application.routes.url_helpers.rails_blob_path(timeline_event_file.file)
    redirect_to destination
  end
end
