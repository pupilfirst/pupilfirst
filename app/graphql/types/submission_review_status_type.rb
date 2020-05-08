module Types
  class SubmissionReviewStatusType < Types::BaseEnum
    value 'Submitted', "Submission that hasn't been reviewed by a coach yet"
    value 'Passed', "Submission that has already been reviewed by a coach with a pass grade"
    value 'Failed', "Submission that has already been reviewed by a coach without a pass grade"
  end
end
