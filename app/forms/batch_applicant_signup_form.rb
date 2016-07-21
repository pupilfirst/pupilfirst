class BatchApplicantSignupForm < Reform::Form
  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
  property :phone, validates: { presence: true, format: { with: /\A[987][0-9]{9}\z/, message: "doesn't look like a mobile phone number" } }
  property :college, validates: { presence: true, length: { minimum: 5 } }
  property :reference
  property :reference_text, virtual: true

  def save(batch)
    applicant = create_applicant
    applicant.send_sign_in_email(batch)
  end

  def create_applicant
    applicant = BatchApplicant.find_or_initialize_by email: email
    applicant.name = name
    applicant.phone = phone
    applicant.college = college

    if applicant.reference.blank?
      applicant.reference = reference_text.present? ? reference_text : reference
    end

    applicant.last_sign_in_at = Time.now
    applicant.save!

    applicant
  end
end
