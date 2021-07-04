module Types
  class CoachType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :user_id, ID, null: false
    field :title, String, null: false
    field :avatar_url, String, null: true
  end

  def name
    object.user.name
  end

  def title
    object.user.full_title
  end

  def user_id
    object.user.id
  end

  def avatar_url
    if object.user.avatar.attached?
      view.rails_representation_path(
        user.avatar_variant(:thumb),
        only_path: true
      )
    end
  end
end
