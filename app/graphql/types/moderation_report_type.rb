module Types
  class ModerationReportType < Types::BaseObject
    field :id, ID, null: false
    field :reason, String, null: false
    field :reportable_id, ID, null: true
    field :reportable_type, String, null: false
    field :user_id, ID, null: false
  end
end
