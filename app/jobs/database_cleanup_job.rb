class DatabaseCleanupJob < ApplicationJob
  queue_as :default

  def perform
    cleanup_connect_slots
    cleanup_submission_files
  end

  private

  # Clean unused connect slots over a week old.
  def cleanup_connect_slots
    slots = ConnectSlot
      .includes(:connect_request)
      .where(connect_requests: { connect_slot_id: nil })
      .where('slot_at < ?', 1.week.ago)

    if slots.count.positive?
      logger.info "Deleting #{slots.count} stale connect slots..."
      slots.destroy_all
    else
      logger.info 'No stale connect slots found.'
    end
  end

  # Delete orphaned submission file attachments over a day old.
  def cleanup_submission_files
    files = TimelineEventFile
      .where(timeline_event_id: nil)
      .where('created_at < ?', 1.day.ago)

    if files.count.positive?
      logger.info "Deleting #{files.count} orphaned timeline event files..."
      files.destroy_all
    else
      logger.info "No orphaned timeline event files found."
    end
  end
end
