module Types
  class SubmissionInfoType < Types::BaseObject
    connection_type_class Types::PupilfirstConnection

    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :evaluated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :passed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :title, String, null: false
    field :level_number, Int, null: false
    field :user_names, String, null: false
    field :feedback_sent, Boolean, null: false
    field :team_name, String, null: true

    def title
      object.target.title
    end

    def level_number
      object.target.target_group.level.number
    end

    def user_names
      object.founders.map { |founder| founder.user.name }.join(', ')
    end

    def feedback_sent
      object.startup_feedback.present?
    end

    def students_have_same_team
      object.founders.distinct(:startup_id).pluck(:startup_id).one?
    end

    def team_name
      if object.team_submission? && students_have_same_team &&
           object.timeline_event_owners.count > 1
        object.founders.first.startup.name
      end
    end
  end
end
