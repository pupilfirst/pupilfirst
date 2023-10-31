class UserStandingsResolver < ApplicationQuery
  property :user_id

  def user_standings
    @user_standings ||= user.user_standings
  end

  def authorized?
    user.school == current_school && current_school_admin.present?
  end

  def user
    @user ||= User.find_by(id: user_id)
  end
end
