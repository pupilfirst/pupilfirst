class CreateStudentsMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :course_id
  property :students
  property :notify_students

  validate :students_must_have_unique_email
  validate :strings_must_not_be_too_long
  validate :emails_must_be_valid
  validate :soft_limit_student_count

  def create_students
    ::Courses::AddStudentsService
      .new(course, notify: notify_students)
      .add(students)
  end

  private

  def valid_string?(string:, max_length:, optional: false)
    return true if string.blank? && optional
    string.length <= max_length
  end

  def strings_must_not_be_too_long
    if students.all? do |s|
         valid_string?(string: s.name, max_length: 250) &&
           valid_string?(string: s.title, max_length: 250, optional: true) &&
           valid_string?(
             string: s.affiliation,
             max_length: 250,
             optional: true
           ) &&
           valid_string?(string: s.team_name, max_length: 50, optional: true)
       end
      return
    end

    errors.add(:base, 'One or more of the entries have invalid strings')
  end

  def emails_must_be_valid
    invalid =
      students.any? do |s|
        s.email !~ EmailValidator::REGULAR_EXPRESSION || s.email.length > 254
      end

    return unless invalid

    errors.add(
      :base,
      'One or more of the entries have an invalid email address'
    )
  end

  def soft_limit_student_count
    return if course.blank? || course.founders.count < 100_000

    errors.add(
      :base,
      "You've hit the soft-limit for number of students in this course"
    )
  end

  def students_must_have_unique_email
    if students.map { |student| student.email.downcase }.uniq.count ==
         students.count
      return
    end

    errors.add(:base, 'Email addresses must be unique')
  end

  def resource_school
    course&.school
  end

  def course
    @course ||= Course.find_by(id: course_id)
  end

  def allow_token_auth?
    true
  end
end
