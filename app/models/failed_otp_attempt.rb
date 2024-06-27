class FailedOtpAttempt < ApplicationRecord
  belongs_to :authenticatable, polymorphic: true

  # Method to count failed attempts within a specific timeframe, e.g., last 24 hours
  # TODO: Read default since from environment.
  def self.count_recent(authenticatable, since: 24.hours.ago)
    where(authenticatable: authenticatable).where(
      "created_at >= ?",
      since
    ).count
  end
end
