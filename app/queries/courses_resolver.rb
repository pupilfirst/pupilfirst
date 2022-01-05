class CoursesResolver < ApplicationQuery
  property :search
  property :status

  def courses
    if search.present?
      applicable_courses.where('name ILIKE ?', "%#{search}%")
    else
      applicable_courses
    end.includes(%i[cover_attachment thumbnail_attachment])
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
    when 'Active'
      current_school
        .courses
        .live
        .where('ends_at > ?', Time.now)
        .or(current_school.courses.live.where(ends_at: nil))
    when 'Ended'
      current_school
        .courses
        .where('ends_at < ?', Time.now)
        .where(archived_at: nil)
    when 'Archived'
      current_school.courses.archived
    else
      raise "#{status} is not a valid status"
    end
  end

  def applicable_courses
    status.blank? ? current_school.courses : filter_by_status
  end
end
