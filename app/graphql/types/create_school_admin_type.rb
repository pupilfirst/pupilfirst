module Types
  class CreateSchoolAdminType < Types::BaseObject
    field :id, ID, null: false
    field :avatar_url, String, null: false

    def avatar_url
      object.user.image_or_avatar_url
    end
  end
end
