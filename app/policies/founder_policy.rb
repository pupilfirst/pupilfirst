class FounderPolicy < ApplicationPolicy
  def show?
    startup = record&.startup
    startup.present? && startup.school == current_school
  end

  def paged_events?
    show?
  end

  def timeline_event_show?
    show?
  end

  def edit?
    show? && record == current_founder
  end

  def update?
    edit?
  end

  def select?
    record.present?
  end
end
