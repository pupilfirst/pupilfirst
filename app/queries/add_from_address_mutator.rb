class AddFromAddressMutator < ApplicationQuery
  property :name, validates: { presence: true, length: { minimum: 1, maximum: 100 } }
  property :email_address, validates: { presence: true, email: true }

  validate :school_must_not_have_from_address

  def add_from_address

  end

  private

  def school_must_not_have_from_address
    return if current_school.configuration["fromAddress"].blank?

    errors[:base] << "Delete the existing email address before attempting to register a new one"
  end

  def authorized?
    return false if current_school_admin.present?

    coach.courses.where(id: coach_note.student.course).exists? && coach_note.author_id == current_user.id
  end

  def coach_note
    @coach_note ||= CoachNote.find_by(id: id)
  end

  def coach
    @coach ||= current_user&.faculty
  end
end
