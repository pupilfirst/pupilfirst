class BatchApplicantSignInForm < Reform::Form
  property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }

  validate :applicant_should_have_application

  def applicant_should_have_application
    if applicant.blank? || applicant.batch_applications.where(batch: Batch.open_batch).blank?
      errors[:base] << "It looks like you haven't applied yet. Start at our application page."
      errors[:email] << 'has not submitted an application'
    end
  end

  def save
    applicant.send_sign_in_email
  end

  def applicant
    @applicant ||= BatchApplicant.find_by email: email
  end
end
