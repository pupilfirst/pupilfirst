module Types
  class StudentSubmissionType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :evaluator_id, ID, null: true
    field :passed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :level_id, ID, null: false
    field :target_id, ID, null: false

    def level_id
      object.target.level.id
    end
  end
end
