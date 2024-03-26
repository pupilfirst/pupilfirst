module Types
  class StudentSubmissionType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :evaluated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :passed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :target_id, ID, null: false
    field :team_target, Boolean, null: false
    field :student_ids, [ID], null: false
    field :milestone_number, Integer, null: true

    def student_ids
      object.student_ids.sort
    end

    def team_target
      object.target.team_target? ? true : false
    end

    def milestone_number
      assignment = object.target.assignments.not_archived.first
      assignment ? assignment.milestone_number : nil
    end
  end
end
