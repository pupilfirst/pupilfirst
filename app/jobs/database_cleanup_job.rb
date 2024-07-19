class DatabaseCleanupJob < ApplicationJob
  queue_as :default

  def perform
    cleanup_submission_files
    cleanup_expired_authentication_tokens
    cleanup_old_failed_input_token_attempts
  end

  private

  # Delete orphaned submission file attachments over a day old.
  def cleanup_submission_files
    files =
      TimelineEventFile.where(timeline_event_id: nil).where(
        "created_at < ?",
        1.day.ago
      )

    if files.count.positive?
      logger.info "Deleting #{files.count} orphaned timeline event files..."
      files.destroy_all
    else
      logger.info "No orphaned timeline event files found."
    end
  end

  def cleanup_expired_authentication_tokens
    AuthenticationToken.expired.delete_all
  end

  def cleanup_old_failed_input_token_attempts
    FailedInputTokenAttempt.where("created_at < ?", 1.day.ago).delete_all
  end
end
