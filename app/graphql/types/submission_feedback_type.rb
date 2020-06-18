module Types
  class SubmissionFeedbackType < Types::BaseObject
    field :id, ID, null: false
    field :value, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :coach_name, String, null: true
    field :coach_avatar_url, String, null: true
    field :coach_title, String, null: false

    def coach_name
      object.faculty&.user&.name
    end

    def coach_title
      object.faculty.user.full_title
    end

    def coach_avatar_url
      object.faculty.user.avatar_url(variant: :thumb)
    end

    def value
      object.feedback
    end
  end
end
