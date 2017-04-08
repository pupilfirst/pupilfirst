class AdmissionsPolicy
  attr_reader :user

  def initialize(user, _admissions)
    @user = user
  end

  def screening?
    level_zero? && target_incomplete?(Target::KEY_ADMISSIONS_SCREENING)
  end

  def screening_submit?
    screening?
  end

  def fee?
    level_zero? && target_complete?(Target::KEY_ADMISSIONS_SCREENING) && target_incomplete?(Target::KEY_ADMISSIONS_FEE_PAYMENT)
  end

  alias fee_submit? fee?
  alias coupon_submit? fee?
  alias coupon_remove? fee?

  def founders?
    level_zero? && target_complete?(Target::KEY_ADMISSIONS_FEE_PAYMENT)
  end

  def founders_submit?
    founders?
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

  def level
    @level ||= user&.founder&.startup&.level
  end

  def level_zero?
    level.number.zero?
  end
end
