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

    return false if current_user.blank?

    current_user.faculty.present?
  end

  def course
    @course ||= current_school.courses.find_by(id: course_id)
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
