module Types
  class MilestonesCompletionStatusType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :completed, Boolean, null: false
    field :milestone_number, Integer, null: false
  end
end
