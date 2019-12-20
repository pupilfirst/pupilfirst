module Types
  class CourseTeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :level_id, ID, null: false
    field :students, [Types::CourseStudentType], null: false
    field :coach_ids, [ID], null: false
    field :access_ends_at, String, null: true
  end
end
