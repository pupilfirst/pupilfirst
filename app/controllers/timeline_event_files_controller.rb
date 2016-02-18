class TimelineEventFilesController < ApplicationController
  # GET /startup/:startup_id/timeline_events/:timeline_event_id/timeline_event_files/:id/download
  def download
    startup = Startup.friendly.find params[:startup_id]
    timeline_event = startup.timeline_events.find params[:timeline_event_id]
    timeline_event_file = timeline_event.timeline_event_files.find params[:id]

    redirect_to timeline_event_file.file.url
  end
end
