class UserStandingsResolver < ApplicationQuery
  include AuthorizeSchoolAdmin
  property :student_id

  def user_standings
    @user_standings ||=
      user.user_standings.where(archived_at: nil).order(created_at: :desc)
  end

  def resource_school
    user&.school
  end

  def user
    @user ||= Student.find_by(id: student_id).user
  end
end
