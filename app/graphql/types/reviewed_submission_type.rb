module Types
  class ReviewedSubmissionType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :created_at, String, null: false
    field :level_id, ID, null: false
    field :target_id, ID, null: false
    field :user_names, String, null: false
    field :feedback_sent, Boolean, null: false
    field :failed, Boolean, null: false
    field :coach_ids, [String], null: false

    def title
      object.target.title
    end

    def level_id
      object.target.target_group.level_id
    end

    def user_names
      object.founders.map do |founder|
        founder.user.name
      end.join(', ')
    end

    def feedback_sent
      object.startup_feedback.present?
    end

    def failed
      object.passed_at.nil?
    end

    def coach_ids
      team_ids = object.founders.map(&:startup_id).uniq
      FacultyStartupEnrollment.where(startup_id: team_ids).pluck(:faculty_id)
    end
  end
end
