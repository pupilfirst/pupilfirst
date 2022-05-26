module Types
  class UserProxyType < Types::BaseObject
    field :id,
          ID,
          null: false,
          description:
            'The ID returned by the type can represent different user role types'
    field :user_id, ID, null: false
    field :name, String, null: false
    field :full_title, String, null: false
    field :avatar_url, String, null: true

    def avatar_url
      object.user.avatar_url(variant: :thumb)
    end
  end
end
