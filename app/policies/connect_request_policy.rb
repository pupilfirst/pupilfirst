class ConnectRequestPolicy < ApplicationPolicy
  def feedback_from_team?
    record.present?
  end

  alias feedback_from_faculty? feedback_from_team?
  alias comment_submit? feedback_from_team?

  def join_session?(token)
    return false unless record.confirmed?

    if token.present?
      record.faculty.present? && Faculty.find_by(token: token) == record.faculty
    else
      record.startup.present? && current_founder&.startup == record.startup
    end
  end
end
