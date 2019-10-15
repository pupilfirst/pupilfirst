module Types
  class SubmissionFeedbackType < Types::BaseObject
    field :id, ID, null: false
    field :value, String, null: false
    field :created_at, String, null: false
    field :coach_name, String, null: false
    field :coach_avatar_url, String, null: false
    field :coach_title, String, null: true
  end

  def value
    object.feedback
  end

  def coach_name
    object.faculty.user.name
  end

  def coach_avatar_url
    object.faculty.user.image_or_avatar_url
  end

  def coach_title
    object.faculty.user.title
  end
end
