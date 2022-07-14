module Types
  class DistributionInLevelType < Types::BaseObject
    field :id, ID, null: false
    field :number, Integer, null: false
    field :students_in_level, Integer, null: false
    field :unlocked, Boolean, null: false
    field :filter_name, String, null: false
  end
end
