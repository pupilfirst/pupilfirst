module Types
  class SubmissionReportType < Types::BaseObject
    field :id, ID, null: false
    field :status, Types::SubmissionReportStatusType, null: false
    field :test_report, String, null: true
    field :started_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :queued_at, GraphQL::Types::ISO8601DateTime, null: false
    field :context, String, null: false
    field :target_url, String, null: true

    def queued_at
      object.created_at
    end
  end
end
