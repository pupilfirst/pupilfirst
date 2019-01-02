class TargetPolicy < ApplicationPolicy
  def download_rubric?
    current_founder.present? && (current_founder.subscription_active? || current_founder.startup&.level_zero?)
  end

  alias prerequisite_targets? download_rubric?
  alias startup_feedback? download_rubric?
  alias details? download_rubric?

  def auto_verify?
    download_rubric? &&
      record.evaluation_criteria.blank? &&
      current_founder.startup.level.course == record.course &&
      current_founder.timeline_events.where(target: record).empty?
  end
end
