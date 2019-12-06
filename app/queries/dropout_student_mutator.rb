class DropoutStudentMutator < ApplicationQuery
  include AuthorizeSchoolAdmin

  property :id, validates: { presence: true }

  validate :student_must_exist

  def execute
    ::Founders::MarkAsExitedService.new(student).execute
  end

  private

  def student_must_exist
    return if student.present?

    errors[:base] << "Unable to find Student with id: #{id}"
  end

  def student
    @student ||= current_school.founders.find(id)
  end
end
