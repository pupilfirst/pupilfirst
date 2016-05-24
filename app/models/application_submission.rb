class ApplicationSubmission < ActiveRecord::Base
  belongs_to :application_stage
  belongs_to :batch_application

  serialize :submission_urls

  def display_name
    "#{batch_application.display_name} ##{id}"
  end
end
