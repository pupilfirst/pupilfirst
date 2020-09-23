module Types
  class SubmissionReviewStatusType < Types::BaseEnum
    value 'PendingReview', "Submission that hasn't been reviewed by a coach yet"
    value 'Completed', "Submission that has already been reviewed by a coach with a pass grade"
    value 'Rejected', "Submission that has already been reviewed by a coach without a pass grade"
  end
end
