module Types
  class DistributionInLevelType < Types::BaseObject
    field :id, ID, null: false
    field :number, Integer, null: false
    field :students_in_level, Integer, null: false
    field :teams_in_level, Integer, null: false
    field :unlocked, Boolean, null: false
  end
end
