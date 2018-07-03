class TimelineEventFilePolicy < ApplicationPolicy
  def download?
    return true unless record.private?
    return false if user.blank?

    startup = record.timeline_event.startup

    is_a_coach = if user.coach.present?
      startup.in? user.coach.startups
    end

    is_a_member = if user.founder.present?
      startup == user.founder.startup
    end

    is_a_coach || is_a_member
  end
end
