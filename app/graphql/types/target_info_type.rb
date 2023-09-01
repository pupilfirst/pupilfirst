module Types
  class TargetInfoType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :milestone_number, Integer, null: true
  end
end
