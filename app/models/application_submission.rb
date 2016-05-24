class ApplicationSubmission < ActiveRecord::Base
  belongs_to :application_stage
  belongs_to :batch_application
  has_many :application_submission_urls

  accepts_nested_attributes_for :application_submission_urls, allow_destroy: true

  def display_name
    "#{batch_application.display_name} - #{application_stage.name}"
  end

  # Stores score from submission URLs.
  def update_score!
    update!(score: latest_score)
  end

  # Retrieves latest score from submission URLs.
  def latest_score
    (application_submission_urls.pluck(:score) - [nil]).inject(:+)
  end
end
