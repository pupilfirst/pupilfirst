class BatchApplicationForm < Reform::Form
  property :consent, virtual: true, validates: { acceptance: true }

  property :team_lead do
    property :name, validates: { presence: true, length: { maximum: 250 } }
    property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
    property :email_confirmation, virtual: true, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
    property :phone, validates: { presence: true, format: { with: /\A[987][0-9]{9}\z/, message: "doesn't look like a mobile phone number" } }
    property :reference
    property :reference_text, virtual: true
  end

  property :university_id, validates: { presence: true }
  property :college, validates: { presence: true, length: { maximum: 250 } }

  # Custom validations.
  validate :do_not_reapply
  validate :university_should_exist
  validate :emails_should_match

  # Applicant with application should be blocked from submitting the form. Zhe should login instead.
  def do_not_reapply
    applicant = BatchApplicant.find_by(email: team_lead.email)

    return if applicant.blank?
    return if applicant.batch_applications.where(batch: Batch.open_batch).blank?

    errors[:base] << 'You have already completed this step. Please sign in instead.'
    team_lead.errors[:email] << 'is already an applicant'
  end

  def university_should_exist
    return if university_id.blank?
    return if University.find(university_id).present?
    errors[:university_id] << 'is invalid'
  end

  def emails_should_match
    return if team_lead.email == team_lead.email_confirmation
    errors[:base] << 'Supplied email address and its confirmation do not match.'
    team_lead.errors[:email_confirmation] << 'email addresses do not match'
  end

  def prepopulate!(options)
    self.team_lead = options[:team_lead]
    self.university_id = University.other.id
  end

  def save
    # TODO: It seems this transaction is not working fine. We are getting applicants without correspoinding applications
    BatchApplication.transaction do
      applicant = update_or_create_team_lead
      application = create_application(applicant)
      application.batch_applicants << applicant

      # Send login email when all's done.
      applicant.send_sign_in_email

      # Return the applicant
      applicant
    end
  end

  def update_or_create_team_lead
    applicant = BatchApplicant.where(email: team_lead.email).first_or_create!

    applicant.update(
      name: team_lead.name,
      phone: team_lead.phone,
      reference: supplied_reference,
      college: college
    )

    add_intercom_applicant_tag_and_details if Rails.env.production?

    applicant
  end

  def create_application(applicant)
    BatchApplication.create!(
      batch: Batch.open_batch,
      application_stage: ApplicationStage.initial_stage,
      university_id: university_id,
      college: college,
      team_lead_id: applicant.id
    )
  end

  def supplied_reference
    team_lead.reference_text.present? ? team_lead.reference_text : team_lead.reference
  end

  def add_intercom_applicant_tag_and_details
    intercom = IntercomClient.new
    user = intercom.find_or_create_user(email: team_lead.email, name: team_lead.name)
    intercom.add_tag_to_user(user, 'Applicant')
    intercom.add_note_to_user(user, 'Auto-tagged as <em>Applicant</em>')
    intercom.add_phone_to_user(user, team_lead.phone)
    intercom.add_college_to_user(user, college)
  rescue
    # simply skip for now if anything goes wrong here
    return
  end
end
