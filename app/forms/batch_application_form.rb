class BatchApplicationForm < Reform::Form
  property :application_page_read, virtual: true, validates: { acceptance: true }
  property :team_lead_consent, virtual: true, validates: { acceptance: true }
  property :fees_consent, virtual: true, validates: { acceptance: true }

  property :team_lead do
    property :name, validates: { presence: true, length: { maximum: 250 } }
    property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
    property :email_confirmation, virtual: true, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
    property :phone, validates: { presence: true, format: { with: /\A[987][0-9]{9}\z/, message: "doesn't look like a mobile phone number" } }
    property :reference
    property :reference_text, virtual: true
  end

  property :university_id, validates: { presence: true }
  properties :college, validates: { presence: true, length: { maximum: 250 } }
  property :cofounder_count, validates: { inclusion: ['', '2', '3', '4'] }

  # Custom validations.
  validate :do_not_reapply
  validate :university_should_exist
  validate :emails_should_match

  # Applicant with application should be blocked from submitting the form. Zhe should login instead.
  def do_not_reapply
    applicant = BatchApplicant.find_by(email: team_lead.email)

    return if applicant.blank?
    return if applicant.batch_applications.where(batch: Batch.open_batch).blank?

    errors[:base] << 'You have already completed this step. Please login instead.'
    team_lead.errors[:email] << 'is already an applicant'
  end

  def university_should_exist
    return if University.find(university_id).present?
    errors[:university_id] << 'is invalid'
  end

  def emails_should_match
    return if team_lead.email == team_lead.email_confirmation
    errors[:base] << 'Supplied email address does not match confirmation.'
    team_lead.errors[:email_confirmation] << 'does not match'
  end

  def prepopulate!(options)
    self.team_lead = options[:team_lead]
    self.cofounder_count = 2
    self.university_id = University.other.id
  end

  def save
    BatchApplication.transaction do
      team_lead = create_team_lead
      application = create_application(team_lead)
      application.batch_applicants << team_lead

      # Send login email when all's done.
      team_lead.send_sign_in_email

      # Return the applicant
      team_lead
    end
  end

  def create_team_lead
    BatchApplicant.create!(
      email: team_lead.email,
      name: team_lead.name,
      phone: team_lead.phone,
      reference: supplied_reference
    )
  end

  def create_application(team_lead)
    BatchApplication.create!(
      batch: Batch.open_batch,
      application_stage: ApplicationStage.initial_stage,
      university_id: university_id,
      college: college,
      team_lead_id: team_lead.id,
      cofounder_count: cofounder_count
    )
  end

  def supplied_reference
    team_lead.reference_text.present? ? team_lead.reference_text : team_lead.reference
  end
end
