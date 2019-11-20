module Types
  class CoachType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :title, String, null: false
    field :avatar_url, String, null: true

    def avatar_url
      user = object.user
      if user.avatar.attached?
        Rails.application.routes.url_helpers.rails_representation_path(user.avatar_variant(:thumb), only_path: true)
      end
    end
  end
end
