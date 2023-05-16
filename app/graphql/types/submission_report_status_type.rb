module Types
  class SubmissionReportStatusType < Types::BaseEnum
    value 'queued', 'Checks are queued'
    value 'in_progress', 'Checks in progress for the submission'
    value 'error', 'Checks could not be completed successfully'
    value 'failure', 'One or more checks failed for the submission'
    value 'success', 'Checks successfully completed for the submission'
  end
end
