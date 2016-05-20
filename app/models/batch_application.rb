class BatchApplication < ActiveRecord::Base
  belongs_to :batch
  belongs_to :application_stage
  has_many :application_stage_scores, dependent: :destroy
  has_many :batch_applicants

  accepts_nested_attributes_for :batch_applicants

  validates :batch_id, presence: true
  validates :application_stage_id, presence: true
end
