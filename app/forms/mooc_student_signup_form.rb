class MoocStudentSignupForm < Reform::Form
  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, virtual: true, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :phone, validates: { presence: true, mobile_number: true }
  property :gender, validates: { presence: true, inclusion: Founder.valid_gender_values }
  property :university_id, validates: { presence: true }
  property :college, validates: { presence: true, length: { maximum: 250 } }
  property :semester, validates: { presence: true, inclusion: MoocStudent.valid_semester_values }
  property :state, validates: { presence: true, length: { maximum: 250 } }

  validate :mooc_student_must_not_exist
  validate :university_id_must_be_valid

  def mooc_student_must_not_exist
    return if email.blank?

    user = User.with_email(email)
    return if user.blank?
    return if user.mooc_student.blank?
    errors[:email] << 'is already registered for the course. Log in instead?'
  end

  def university_id_must_be_valid
    return if university_id.blank? # Presence validator will show correct message.
    return if University.find_by(id: university_id).present?
    errors[:university_id] << 'is invalid'
  end

  def prepopulate!(options)
    self.email = options[:email]
  end

  def save
    MoocStudents::RegistrationService.new(to_nested_hash).register
  end
end
