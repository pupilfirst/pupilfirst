class DropoutStudentMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id, validates: { presence: true }

  validate :active_student_must_exist

  def execute
    ::Founders::MarkAsDroppedOutService.new(student, current_user).execute
  end

  private

  def resource_school
    student&.school
  end

  def active_student_must_exist
    return if student.present? && !student.dropped_out?

    errors[:base] << "Unable to find an active student with id: #{id}"
  end

  def student
    @student ||= Founder.find_by(id: id)
  end
end
