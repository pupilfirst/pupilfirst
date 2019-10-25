module Types
  class CreateSchoolAdminType < Types::BaseObject
    field :id, ID, null: false
    field :avatar_url, String, null: true

    def avatar_url
      object.user.avatar_url(variant: :thumb)
    end
  end
end
