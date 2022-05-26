class StudentResolver < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :student_id

  def student
    @student ||= current_school.founders.find_by(id: student_id)
  end

  def resource_school
    student&.school
  end
end
