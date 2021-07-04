module Types
  class LevelType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :number, Integer, null: false
  end
end
