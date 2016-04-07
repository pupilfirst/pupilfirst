class DatabaseCleanupJob < ActiveJob::Base
  queue_as :default

  def perform
    # Clean unused connect slots over a week old.
    slots = ConnectSlot
      .includes(:connect_request)
      .where(connect_requests: { connect_slot_id: nil })
      .where('slot_at < ?', 1.week.ago)

    if slots.count > 0
      logger.info "Deleting #{slots.count} stale connect slots..."
      slots.destroy_all
    else
      logger.info 'No stale connect slots found. Bye bye.'
    end
  end
end
