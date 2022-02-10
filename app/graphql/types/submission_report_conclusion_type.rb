module Types
  class SubmissionReportConclusionType < Types::BaseEnum
    value 'error', 'Checks could not be completed successfully'
    value 'failure', 'One or more checks failed for the submission'
    value 'success', 'Checks successfully completed for the submission'
  end
end
