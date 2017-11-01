class ConnectRequestPolicy < ApplicationPolicy
  def feedback_from_team?
    record.present?
  end

  alias feedback_from_faculty? feedback_from_team?

  def join_session?(token)
    return false if record.unconfirmed?
    if token.present?
      record.faculty.present? && Faculty.find_by(token: token) == record.faculty
    else
      record.startup.present? && user&.founder&.startup == record.startup
    end
  end
end
