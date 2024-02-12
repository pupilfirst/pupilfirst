class UserStandingsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :user_id

  def user_standings
    @user_standings ||= user.user_standings.live.order(created_at: :desc)
  end

  def resource_school
    user&.school
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def allow_token_auth?
    true
  end
end
