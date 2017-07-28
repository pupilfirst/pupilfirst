class TimelineEventFilesController < ApplicationController
  # GET /startup/:startup_id/timeline_events/:timeline_event_id/timeline_event_files/:id/download
  def download
    timeline_event_file = TimelineEventFile.find(params[:id])
    authorize timeline_event_file

    redirect_to timeline_event_file.file.url
  end
end
