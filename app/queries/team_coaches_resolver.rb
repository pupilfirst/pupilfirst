class TeamCoachesResolver < ApplicationQuery
  property :search
  property :course_id

  def team_coaches
    if search.present?
      applicable_team_coaches.where('user.name ILIKE ?', "%#{search}%")
    else
      applicable_team_coaches
    end
  end

  private

  def authorized?
    return false if course.blank?

    current_coach.present?
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def applicable_team_coaches
    course
      .faculty
      .joins(startups: :course)
      .where(startups: { courses: { id: course.id } })
      .includes(user: { avatar_attachment: :blob })
      .distinct
  end
end
