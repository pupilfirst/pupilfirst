module Types
  class NoteAuthorType < Types::BaseObject
    field :name, String, null: false
    field :title, String, null: false
    field :avatar_url, String, null: true
    field :user_id, String, null: false

    def avatar_url
      if object.avatar.attached?
        Rails.application.routes.url_helpers.rails_representation_path(object.avatar_variant(:thumb), only_path: true)
      end
    end

    def title
      object.full_title
    end
  end
end
