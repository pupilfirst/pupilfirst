module Types
  class SubmissionReviewResultType < Types::BaseEnum
    value 'Pending', "Submission that hasn't been reviewed by a coach yet"
    value 'Passed', "Submission that has already been reviewed by a coach with a pass grade"
    value 'Failed', "Submission that has already been reviewed by a coach without a pass grade"
  end
end
