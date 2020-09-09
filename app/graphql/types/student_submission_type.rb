module Types
  class StudentSubmissionType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :evaluated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :passed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :level_id, ID, null: false
    field :target_id, ID, null: false
    field :team_target, Boolean, null: false
    field :student_ids, [ID], null: false

    def level_id
      object.target.level.id
    end

    def student_ids
      object.founder_ids.sort
    end

    def team_target
      object.target.team_target? ? true : false
    end
  end
end
