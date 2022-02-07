module Types
  class SubmissionReportStatusType < Types::BaseEnum
    value 'queued', 'automated tests are queued'
    value 'in_progress', 'checks in progress for the submission'
    value 'completed', 'checks completed for the submission'
  end
end
