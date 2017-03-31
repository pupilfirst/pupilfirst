class AdmissionsPolicy
  attr_reader :user

  def initialize(user, _admissions)
    @user = user
  end

  def screening?
    user_level = user&.founder&.startup&.level

    # User's startup level should be available.
    return false if user_level.nil?

    # User's startup level should be zero.
    return false if user_level != 0

    # User should not have completed the related target.
    screening_target = user.founder.targets.find_by(key: Target::KEY_ADMISSIONS_SCREENING)

    screening_target.status != Targets::StatusService::STATUS_COMPLETE
  end

  def screening_submit?
    screening?
  end
end
