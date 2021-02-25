module Types
  class ApplicantType < Types::BaseObject
    connection_type_class Types::PupilfirstConnection
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false
    field :tags, [String], null: false

    def tags
      object.taggings.map { |tagging| tagging.tag.name }
    end
  end
end
