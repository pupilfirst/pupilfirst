class BatchApplication < ActiveRecord::Base
  belongs_to :batch
  belongs_to :application_stage
  has_many :application_submissions, dependent: :destroy
  has_many :batch_applicants, dependent: :destroy

  accepts_nested_attributes_for :batch_applicants

  validates :batch_id, presence: true
  validates :application_stage_id, presence: true

  def display_name
    batch_applicants.find_by(team_lead: true).name
  end
end
