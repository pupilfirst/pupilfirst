class BatchApplicationForm < Reform::Form
  include CollegeAddable

  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
  property :email_confirmation, virtual: true, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
  property :phone, validates: { presence: true, format: { with: /\A[987][0-9]{9}\z/, message: "doesn't look like a mobile phone number" } }
  property :reference
  property :reference_text, virtual: true
  property :college_id, validates: { presence: true }
  property :college_text, validates: { length: { maximum: 250 } }

  # Custom validations.
  validate :do_not_reapply
  validate :college_should_exist
  validate :emails_should_match

  # Applicant with application should be blocked from submitting the form. Zhe should login instead.
  def do_not_reapply
    applicant = BatchApplicant.find_by(email: email)

    return if applicant.blank?
    return if applicant.batch_applications.where(batch: Batch.open_batch).blank?

    errors[:base] << 'You have already completed this step. Please sign in instead.'
    errors[:email] << 'is already an applicant'
  end

  def college_should_exist
    return if college_id.blank?
    return if college_id == 'other'
    return if College.find(college_id).present?

    errors[:college_id] << 'is invalid'
  end

  def emails_should_match
    return if email == email_confirmation
    errors[:base] << 'Supplied email address and its confirmation do not match.'
    errors[:email_confirmation] << 'email addresses do not match'
  end

  def save
    applicant = nil

    BatchApplication.transaction do
      applicant = update_or_create_team_lead
      application = create_application(applicant)
      application.batch_applicants << applicant

      # Send login email when all's done.
      applicant.send_sign_in_email(defer: true)
    end

    # Update user info on intercom
    IntercomNewApplicantCreateJob.perform_later applicant if applicant.present?

    # Return the applicant
    applicant
  end

  def update_or_create_team_lead
    applicant = BatchApplicant.where(email: email).first_or_create!

    applicant.update(
      {
        name: name,
        phone: phone,
        reference: supplied_reference
      }.merge(college_details)
    )

    applicant
  end

  def create_application(applicant)
    BatchApplication.create!(
      batch: Batch.open_batch,
      application_stage: ApplicationStage.initial_stage,
      team_lead_id: applicant.id
    )
  end

  def supplied_reference
    reference_text.present? ? reference_text : reference
  end
end
