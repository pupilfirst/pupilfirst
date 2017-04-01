class AdmissionsPolicy
  attr_reader :user

  def initialize(user, _admissions)
    @user = user
  end

  def screening?
    return false if level.number != 0
    target_incomplete?(Target::KEY_ADMISSIONS_SCREENING)
  end

  def screening_submit?
    screening?
  end

  def founders?
    return false if level.number != 0
    target_incomplete?(Target::KEY_ADMISSIONS_COFOUNDER_ADDITION)
  end

  def founders_submit?
    founders?
  end

  private

  # User should not have completed the related target.
  def target_incomplete?(key)
    target = Target.find_by(key: key)
    target.status(user.founder) != Targets::StatusService::STATUS_COMPLETE
  end

  def level
    @level ||= user&.founder&.startup&.level
  end
end
