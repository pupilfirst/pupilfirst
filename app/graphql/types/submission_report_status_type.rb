module Types
  class SubmissionReportStatusType < Types::BaseEnum
    value 'queued', 'Automated tests are queued'
    value 'in_progress', 'Checks in progress for the submission'
    value 'completed', 'Checks completed for the submission'
  end
end
