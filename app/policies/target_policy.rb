class TargetPolicy < ApplicationPolicy
  def prerequisite_targets?
    current_founder.present?
  end

  alias startup_feedback? prerequisite_targets?
  alias details? prerequisite_targets?

  def auto_verify?
    prerequisite_targets? &&
      record.evaluation_criteria.blank? &&
      current_founder.startup.level.course == record.course &&
      current_founder.timeline_events.where(target: record).empty?
  end
end
