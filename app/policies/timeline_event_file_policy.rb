class TimelineEventFilePolicy < ApplicationPolicy
  def download?
    return true unless record.private?
    return false if user&.founder.blank?

    # Allow download of private timeline event files to members of the owning startup.
    record.timeline_event.startup == user.founder.startup
  end
end
