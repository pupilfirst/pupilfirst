module Types
  class UserStandingType < BaseObject
    field :id, ID, null: false
    field :standing_name, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :creator_name, String, null: false
    field :reason, String, null: false

    def creator_name
      object.creator.name
    end

    def standing_name
      object.standing.name
    end
  end
end
