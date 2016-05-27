class BatchApplication < ActiveRecord::Base
  belongs_to :batch
  belongs_to :application_stage
  has_many :application_submissions, dependent: :destroy
  has_and_belongs_to_many :batch_applicants
  belongs_to :team_lead, class_name: 'BatchApplicant'

  validates :batch_id, presence: true
  validates :application_stage_id, presence: true

  def display_name
    team_lead&.name || "Batch Application ##{id}"
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
end
