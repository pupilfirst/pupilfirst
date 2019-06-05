class CoursesResolver < ApplicationResolver
  def collection
    if current_school_admin.present?
      current_school.courses
    else
      School.none
    end
  end
end
