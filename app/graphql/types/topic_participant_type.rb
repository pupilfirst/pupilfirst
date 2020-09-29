module Types
  class TopicParticipantType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :avatar_url, String, null: true

    def avatar_url
      object.avatar_url(variant: :thumb)
    end
  end
end
