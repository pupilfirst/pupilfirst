class SubmissionModeration < ApplicationRecord
  belongs_to :user
  belongs_to :timeline_event
end
