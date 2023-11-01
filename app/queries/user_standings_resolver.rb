class UserStandingsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :user_id

  def user_standings
    @user_standings ||= user.user_standings.where(archived_at: nil)
  end

  def resource_school
    user&.school
  end

  def user
    @user ||= User.find_by(id: user_id)
  end
end
