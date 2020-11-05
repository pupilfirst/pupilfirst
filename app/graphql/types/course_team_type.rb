module Types
  class CourseTeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :tags, [String], null: false
    field :level_id, ID, null: false
    field :students, [Types::CourseStudentType], null: false
    field :coach_ids, [ID], null: false
    field :access_ends_at, GraphQL::Types::ISO8601DateTime, null: true

    def coach_ids
      object.faculty_startup_enrollments.pluck(:faculty_id)
    end

    def tags
      object.taggings.map { |tagging| tagging.tag.name }
    end

    def students
      object.founders
    end
  end
end
