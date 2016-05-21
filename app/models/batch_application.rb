class BatchApplication < ActiveRecord::Base
  belongs_to :batch
  belongs_to :application_stage
  has_many :application_submissions, dependent: :destroy
  has_many :batch_applicants, dependent: :destroy

  accepts_nested_attributes_for :batch_applicants

  validates :batch_id, presence: true
  validates :application_stage_id, presence: true

  def display_name
    team_lead.name
  end

  def team_lead
    batch_applicants.find_by(team_lead: true)
  end

  def score
    application_submissions.find_by(application_stage_id: application_stage.id)&.score
  end

  # Promotes this application to the next stage, and returns the latest stage.
  def promote!
    self.application_stage = application_stage.next
    save!
    application_stage
  end
end
