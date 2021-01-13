class CreateStudentsMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id

  collection :students do
    property :name, validates: { length: { maximum: 250 } }
    property :email, validates: { email: true }
    property :title, validates: { length: { maximum: 250 } }
    property :affiliation, validates: { length: { maximum: 250 } }
    property :tags
    property :team_name, validates: { length: { maximum: 50 } }
  end

  property :notify_students

  validate :students_must_have_unique_email

  def create_students
    ::Courses::AddStudentsService.new(course, notify: notify_students).add(students)
  end

  private

  def students_must_have_unique_email
    return if students.map(&:email).uniq.count == students.count

    errors[:base] << 'Email addresses must be unique'
  end

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end
end
