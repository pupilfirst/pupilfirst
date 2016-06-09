class BatchApplicant < ActiveRecord::Base
  has_and_belongs_to_many :batch_applications
  has_many :applications_as_lead, class_name: 'BatchApplication', foreign_key: 'team_lead_id'

  # Basic validations.
  validates :email, presence: true, uniqueness: true
  validates :gender, inclusion: Founder.valid_gender_values, allow_nil: true, unless: proc { source?(:sign_up) }
  validates :role, inclusion: Founder.valid_roles, allow_nil: true, unless: proc { source?(:sign_up) }

  # Custom validations.
  validate :email_must_look_right

  def email_must_look_right
    errors[:email] << "doesn't look like an email" unless email =~ /\S+@\S+/
  end

  has_secure_token

  attr_accessor :source

  def source?(*sources)
    sources.include? source
  end

  # Attempts to find an applicant with the supplied token. If found, the token is regenerated to invalidate previous
  # value, thus preventing reuse of login link.
  def self.find_using_token(incoming_token)
    applicant = find_by token: incoming_token
    return if applicant.blank?
    applicant.regenerate_token
    applicant
  end

  def applied_to?(batch)
    return false unless batch_applications.present?

    batch_applications.find_by(batch_id: batch.id).present?
  end

  # Creates an application and associated applicant entries.
  def create_application(batch, params)
    stage = batch.application_stage

    application = params[:batch_application]

    BatchApplication.transaction do
      # Create the application.
      batch_application = BatchApplication.create!(
        batch: batch,
        application_stage: stage,
        team_lead: self,
        university: University.find_by(id: application[:university_id]),
        college: application[:college],
        state: application[:state],
        team_achievement: application[:team_achievement]
      )

      # Update the team lead's information.
      update!(
        name: application[:team_lead_name],
        gender: application[:team_lead_gender]
      )

      # Own the application.
      batch_applications << batch_application

      # Create and link co-founders.
      cofounders_count = application[:cofounders_count]
      cofounders_count = 2 unless cofounders_count.in?([2, 3, 4])

      (1..cofounders_count).each do |index|
        cofounder = params["cofounder_#{index}"]
        applicant = BatchApplicant.find_or_initialize_by(email: cofounder[:email])
        applicant.name = cofounder[:name]
        applicant.role = cofounder[:role]
        applicant.save!

        batch_application.batch_applicants << applicant
      end
    end

    true
  rescue ActiveRecord::RecordInvalid => _e
    binding.pry
    false
  end
end
