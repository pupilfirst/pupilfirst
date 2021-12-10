module Types
  class SubmissionReportType < Types::BaseObject
    field :id, ID, null: false
    field :status, Types::SubmissionReportStatusType, null: false
    field :description, String, null: false
  end
end