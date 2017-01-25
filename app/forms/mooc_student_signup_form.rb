class MoocStudentSignupForm < Reform::Form
  include CollegeAddable
  include EmailBounceValidatable

  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, virtual: true, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :phone, validates: { presence: true, mobile_number: true }
  property :gender, validates: { presence: true, inclusion: Founder.valid_gender_values }
  property :college_id, validates: { presence: true }
  property :college_text, validates: { length: { maximum: 250 } }
  property :semester, validates: { presence: true, inclusion: MoocStudent.valid_semester_values }
  property :state, validates: { presence: true, length: { maximum: 250 } }

  validate :mooc_student_must_not_exist

  def mooc_student_must_not_exist
    return if email.blank?

    user = User.with_email(email).first
    return if user.blank?
    return if user.mooc_student.blank?
    errors[:email] << 'is already registered for the course. Log in instead?'
  end

  def prepopulate!(options)
    self.email = options[:email]
  end

  def save(send_sign_in_email:)
    MoocStudents::RegistrationService.new(to_nested_hash, send_sign_in_email).register
  end
end
