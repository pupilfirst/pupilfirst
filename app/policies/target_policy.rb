class TargetPolicy < ApplicationPolicy
  def download_rubric?
    current_founder.present? && (current_founder.subscription_active? || current_founder.startup&.level_zero?)
  end

  alias prerequisite_targets? download_rubric?
  alias startup_feedback? download_rubric?
  alias details? download_rubric?

  def auto_verify?
    download_rubric? &&
      record.submittability == Target::SUBMITTABILITY_AUTO_VERIFY &&
      current_founder.startup.level.school == record.school
  end
end
