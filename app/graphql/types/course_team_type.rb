module Types
  class CourseTeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :level_id, ID, null: false
    field :students, [Types::CourseStudentType], null: false
    field :coach_ids, [ID], null: false
    field :access_ends_at, GraphQL::Types::ISO8601DateTime, null: true

    def coach_ids
      object.faculty_startup_enrollments.pluck(:faculty_id)
    end

    def students
      object.founders.map do |student|
        student_props = {
          id: student.id,
          name: student.user.name,
          email: student.user.email,
          team_id: student.startup_id,
          tags: student.taggings.map { |tagging| tagging.tag.name },
          excluded_from_leaderboard: student.excluded_from_leaderboard,
          title: student.user.title,
          affiliation: student.user.affiliation
        }

        if student.user.avatar.attached?
          student_props[:avatar_url] = Rails.application.routes.url_helpers.rails_representation_path(student.user.avatar_variant(:thumb), only_path: true)
        end

        student_props
      end
    end
  end
end
