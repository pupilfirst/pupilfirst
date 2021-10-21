module Types
  class SubmissionReportStatusType < Types::BaseEnum
    value 'error', 'Checks could not be completed successfully'
    value 'failure', 'one or more checks failed for the submission'
    value 'pending', 'checks in progress for the submission'
    value 'success', 'checks successfully completed for the submission'
  end
end
