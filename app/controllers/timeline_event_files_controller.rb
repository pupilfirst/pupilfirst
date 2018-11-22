class TimelineEventFilesController < ApplicationController
  # GET /timeline_event_files/:id/download
  def download
    timeline_event_file = authorize(TimelineEventFile.find(params[:id]))
    redirect_to timeline_event_file.file.url
  end
end
