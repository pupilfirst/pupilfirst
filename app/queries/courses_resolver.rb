class CoursesResolver < ApplicationQuery
  property :search
  property :status

  def courses
    if search.present?
      applicable_courses.where("courses.name ILIKE ?", "%#{search}%")
    else
      applicable_courses
    end.order(sort_index: :asc)
  end

  def allow_token_auth?
    true
  end

  private

  def authorized?
    current_school_admin.present?
  end

  def filter_by_status
    case status
    when "Active"
      current_school.courses.active
    when "Ended"
      current_school.courses.ended
    when "Archived"
      current_school.courses.archived
    else
      raise "#{status} is not a valid status"
    end
  end

  def applicable_courses
    status.blank? ? current_school.courses : filter_by_status
  end
end
