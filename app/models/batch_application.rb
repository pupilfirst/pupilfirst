class BatchApplication < ActiveRecord::Base
  belongs_to :batch
  belongs_to :application_stage
  has_many :application_submissions, dependent: :destroy
  has_and_belongs_to_many :batch_applicants
  belongs_to :team_lead, class_name: 'BatchApplicant'
  belongs_to :university

  scope :selected, -> { joins(:application_stage).where(application_stages: { final_stage: true }) }

  validates :batch_id, presence: true
  validates :application_stage_id, presence: true
  validates :university_id, presence: true
  validates :college, presence: true
  validates :state, presence: true
  validates :team_achievement, presence: true

  def display_name
    if team_lead.present?
      "#{team_lead&.name} (#{batch.name})"
    else
      "Batch Application ##{id}"
    end
  end

  def score
    application_submissions.find_by(application_stage_id: application_stage.id)&.score
  end

  # Promotes this application to the next stage, and returns the latest stage.
  def promote!
    return application_stage unless promotable?
    self.application_stage = application_stage.next
    save!
    application_stage
  end

  # Application is promotable is it's on the same stage as its batch.
  def promotable?
    application_stage == batch.application_stage
  end

  def save_code_and_video_submissions!(code_url:, video_url:)
    ApplicationSubmission.transaction do
      submission = application_submissions.create!(application_stage: application_stage)

      submission.application_submission_urls.create!(
        name: 'Code Submission',
        url: code_url
      )

      submission.application_submission_urls.create!(
        name: 'Video Submission',
        url: video_url
      )
    end

    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end
