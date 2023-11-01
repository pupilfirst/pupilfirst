module Types
  class StandingType < BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
  end
end
