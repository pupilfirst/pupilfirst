class DatabaseCleanupJob < ApplicationJob
  queue_as :default

  def perform
    cleanup_submission_files
  end

  private

  # Delete orphaned submission file attachments over a day old.
  def cleanup_submission_files
    files =
      TimelineEventFile
        .where(timeline_event_id: nil)
        .where('created_at < ?', 1.day.ago)

    if files.count.positive?
      logger.info "Deleting #{files.count} orphaned timeline event files..."
      files.destroy_all
    else
      logger.info 'No orphaned timeline event files found.'
    end
  end
end
