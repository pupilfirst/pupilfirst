class BatchApplication < ActiveRecord::Base
  belongs_to :batch
  belongs_to :application_stage
  has_many :application_stage_scores
  has_many :application_founders
end
