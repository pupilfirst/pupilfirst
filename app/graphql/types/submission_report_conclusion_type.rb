module Types
  class SubmissionReportConclusionType < Types::BaseEnum
    value 'error', 'checks could not be completed successfully'
    value 'failure', 'one or more checks failed for the submission'
    value 'success', 'checks successfully completed for the submission'
  end
end
