module Types
  class StudentSubmissionType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :passed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :level_id, String, null: false
    field :grades, [Types::GradeType], null: false

    def level_id
      object.target.level.id
    end

    def grades
      object.timeline_event_grades
    end
  end
end
