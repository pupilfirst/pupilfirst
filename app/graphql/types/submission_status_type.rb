module Types
  class SubmissionStatusType < Types::BaseEnum
    value 'Pending', "Submission that hasn't been reviewed by a coach yet"
    value 'Reviewed', "Submission that has already been reviewed by a coach"
  end
end
