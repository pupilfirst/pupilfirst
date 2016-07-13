class MoocStudentSignupForm < Reform::Form
  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, virtual: true, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
  property :gender, validates: { presence: true, inclusion: Founder.valid_gender_values }
  property :university_id, validates: { presence: true }
  property :college, validates: { presence: true, length: { maximum: 250 } }
  property :semester, validates: { presence: true, inclusion: MoocStudent.valid_semester_values }
  property :state, validates: { presence: true, length: { maximum: 250 } }

  validate :mooc_student_must_not_exist
  validate :university_id_must_be_valid

  def mooc_student_must_not_exist
    user = User.find_by(email: email)
    return if user.blank?
    return if user.mooc_student.blank?
    errors[:email] << 'is already registered for the course. Log in instead?'
  end

  def university_id_must_be_valid
    return if University.find_by(id: university_id).present?
    errors[:university_id] << 'is invalid'
  end

  def prepopulate!(options)
    self.email = options[:email]
  end

  def save(referer:)
    User.transaction do
      # Find or create the user entry.
      user = User.where(email: email).first_or_create!

      # Find or initialize the user entry.
      mooc_student = MoocStudent.where(user_id: user.id).first_or_initialize

      mooc_student.name = name
      mooc_student.gender = gender
      mooc_student.university_id = university_id
      mooc_student.college = college
      mooc_student.semester = semester
      mooc_student.state = state

      mooc_student.save!

      # Send the user a login email.
      user.referer = referer
      user.send_login_email

      # Return the user
      user
    end
  end
end
