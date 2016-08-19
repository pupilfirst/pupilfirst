class BatchApplicantSignInForm < Reform::Form
  property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
  property :shared_device, virtual: true

  validate :applicant_should_have_application

  def applicant_should_have_application
    if applicant.blank? || applicant.batch_applications.blank?
      errors[:base] << "It looks like you haven't applied yet. Start at our application page."
      errors[:email] << 'has not submitted an application'
    end
  end

  def save
    applicant.send_sign_in_email(shared_device: shared_device?)
  end

  def applicant
    @applicant ||= BatchApplicant.find_by email: email
  end

  def shared_device?
    shared_device == '1'
  end
end
