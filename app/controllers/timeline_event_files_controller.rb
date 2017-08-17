class TimelineEventFilesController < ApplicationController
  # GET /timeline_event_files/:id/download
  def download
    timeline_event_file = TimelineEventFile.find(params[:id])
    authorize timeline_event_file
    redirect_to timeline_event_file.file.url
  end
end
