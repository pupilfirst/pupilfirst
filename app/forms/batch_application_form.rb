class BatchApplicationForm < Reform::Form
  property :application_page_read, virtual: true, validates: { acceptance: true }
  property :team_lead_consent, virtual: true, validates: { acceptance: true }
  property :fees_consent, virtual: true, validates: { acceptance: true }

  property :team_lead do
    property :name, validates: { presence: true, length: { maximum: 250 } }
    property :email, validates: { presence: true, length: { maximum: 250 }, format: { with: /\S+@\S+/, message: "doesn't look like an email" } }
    property :phone, validates: { presence: true, format: { with: /\A[987][0-9]{9}\z/, message: "doesn't look like a mobile phone number" } }
  end

  property :university_id, validates: { presence: true }
  properties :college, validates: { presence: true, length: { maximum: 250 } }
  property :cofounder_count, validates: { presence: true, inclusion: %w(2 3 4) }
  property :reference
  property :reference_text, virtual: true

  # Custom validations.
  validate :do_not_repeat
  validate :university_should_exist

  # Applicant with application should be blocked from submitting the form. Zhe should login instead.
  def do_not_reapply
    applicant = BatchApplicant.find_by(email: email)
    return if applicant&.batch_application.blank?
    errors[:base] << 'You have already completed this step. Please login instead.'
    errors[:email] << 'is already an applicant'
  end

  def university_should_exist
    return if University.find(university_id).present?
    errors[:university_id] << 'is invalid'
  end

  def prepopulate!(options)
    self.team_lead = options[:team_lead]
    self.cofounder_count = 2
  end

  def save(batch_number)
    BatchApplication.transaction do
      team_lead = create_team_lead
      create_application(team_lead)

      # Send login email when all's done.
      applicant.send_sign_in_email(batch_number)
    end
  end

  def create_team_lead
    BatchApplicant.create!(
      email: email,
      name: name,
      gender: gender,
      phone: phone
    )
  end

  def create_application(team_lead)
    BatchApplication.create!(
      university_id: university_id,
      team_achievement: team_achievement,
      college: college,
      state: state,
      team_lead_id: team_lead.id
    )
  end
end
