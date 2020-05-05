module Types
  class SubmissionReviewResultType < Types::BaseEnum
    value 'pending', "Submission that hasn't been reviewed by a coach yet"
    value 'passed', "Submission that has already been reviewed by a coach with a pass grade"
    value 'failed', "Submission that has already been reviewed by a coach without a pass grade"
  end
end
