class AdmissionsPolicy < ApplicationPolicy
  def screening?
    level_zero? && target_incomplete?(Target::KEY_ADMISSIONS_SCREENING)
  end

  def screening_submit?
    level_zero? && FounderPolicy.new(user, user.founder).screening_submit?
  end

  def coupon_submit?
    FounderPolicy.new(user, user.founder).fee? && user.founder.startup.applied_coupon.blank?
  end

  def coupon_remove?
    FounderPolicy.new(user, user.founder).fee? && user.founder.startup.applied_coupon.present?
  end

  def founders?
    level_zero? && target_complete?(Target::KEY_ADMISSIONS_SCREENING)
  end

  def founders_submit?
    founders?
  end

  def team_lead?
    founders? && !user.founder.team_lead?
  end

  def accept_invitation?
    # Authorization is handled in the controller using supplied token.
    true
  end

  private

  # User should not have completed the related target.
  def target_incomplete?(key)
    target = Target.find_by(key: key)
    target.status(user.founder) != Targets::StatusService::STATUS_COMPLETE
  end

  # User should have completed the prerequisite target.
  def target_complete?(key)
    target = Target.find_by(key: key)
    target.status(user.founder) == Targets::StatusService::STATUS_COMPLETE
  end

  def target_pending?(key)
    target = Target.find_by(key: key)
    target.pending?(user.founder)
  end

  def level
    @level ||= user&.founder&.startup&.level
  end

  def level_zero?
    level&.number&.zero?
  end
end
