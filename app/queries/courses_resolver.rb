class CoursesResolver < ApplicationQuery
  property :search
  property :archived

  def courses
    if search.present?
      applicable_courses.search_by_name(name_for_search)
    else
      applicable_courses
    end
  end

  def allow_token_auth?
    true
  end

  private

  def authorized?
    current_school_admin.present?
  end

  def name_for_search
    search.strip
          .gsub(/[^a-z\s0-9]/i, '')
          .split(' ').reject do |word|
      word.length < 3
    end.join(' ')[0..50]
  end

  def applicable_courses
    if archived.present?
      archived ? current_school.courses.archived : current_school.courses.live
    else
      current_school.courses
    end
  end
end
