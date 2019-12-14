class DropoutStudentMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id, validates: { presence: true }

  validate :active_student_must_exist

  def execute
    ::Founders::MarkAsDroppedOutService.new(student).execute
  end

  private

  def active_student_must_exist
    return if student.present? && !student.dropped_out?

    errors[:base] << "Unable to find an active student with id: #{id}"
  end

  def student
    @student ||= current_school.founders.find_by(id: id)
  end
end
