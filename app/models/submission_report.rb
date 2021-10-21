class SubmissionReport < ApplicationRecord
  belongs_to :submission, class_name: 'TimelineEvent'

  validates :description, presence: true
  validates :status, presence: true

  enum status: {
         error: 'error',
         failure: 'failure',
         pending: 'pending',
         success: 'success'
       }
end
