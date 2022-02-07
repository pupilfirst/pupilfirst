class SubmissionReport < ApplicationRecord
  belongs_to :submission, class_name: 'TimelineEvent'

  validates :status, presence: true

  enum status: {
         queued: 'queued',
         in_progress: 'in_progress',
         completed: 'completed'
       }

  enum conclusion: { success: 'success', failure: 'failure', error: 'error' }
end
