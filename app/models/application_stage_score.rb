class ApplicationStageScore < ActiveRecord::Base
  belongs_to :application_stage
  belongs_to :batch_application

  serialize :submission_urls
end
