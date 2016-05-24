class BatchApplication < ActiveRecord::Base
  belongs_to :batch
  belongs_to :application_stage
  has_many :application_submissions, dependent: :destroy
  has_many :batch_applicants, dependent: :destroy

  accepts_nested_attributes_for :batch_applicants

  validates :batch_id, presence: true
  validates :application_stage_id, presence: true

  def display_name
    team_lead&.name || "Batch Application ##{id}"
  end

  def team_lead
    batch_applicants.find_by(team_lead: true)
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

  # Application is promotable is it's on the same stage as its batch, and has a score.
  def promotable?
    application_stage == batch.application_stage && score.present?
  end
end
