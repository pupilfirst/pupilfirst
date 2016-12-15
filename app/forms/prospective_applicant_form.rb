class ProspectiveApplicantForm < Reform::Form
  include CollegeAddable

  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, validates: { presence: true, email: true, length: { maximum: 250 } }
  property :phone, validates: { presence: true, mobile_number: true }
  property :college_id, validates: { presence: true }
  property :college_text, validates: { length: { maximum: 250 } }

  validate :email_must_not_be_bounced

  def email_must_not_be_bounced
    return if email.blank?

    user = User.with_email(email).first
    return if user.blank?
    errors[:email] << 'previous mails to this address were bouncing! Supply a different one.' if user.email_bounced
  end

  def save
    prospective_applicant = ProspectiveApplicant.with_email(email).first
    prospective_applicant = ProspectiveApplicant.new(email: email) if prospective_applicant.blank?

    prospective_applicant.update!({
      name: name,
      phone: phone
    }.merge(college_details))

    prospective_applicant
  end
end
