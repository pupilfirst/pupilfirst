class CoursesResolver < ApplicationQuery
  property :search
  property :archived

  def courses
    if search.present?
      applicable_courses.search_by_name(search)
    else
      applicable_courses.includes([:cover_attachment, :thumbnail_attachment])
    end
  end

  def allow_token_auth?
    true
  end

  private

  def authorized?
    current_school_admin.present?
  end

  def applicable_courses
    if archived.nil?
      current_school.courses
    else
      archived ? current_school.courses.archived : current_school.courses.live
    end
  end
end
