class TimelineEventFilePolicy < ApplicationPolicy
  def download?
    return true unless record.private?
    return false if user.blank?

    startup = record.timeline_event.startup

    is_a_coach = user.coached_startups.where(id: startup.id).exists?
    is_a_member = current_founder&.startup.present?

    is_a_coach || is_a_member
  end
end
