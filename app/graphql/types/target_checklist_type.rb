module Types
  class TargetChecklistType < Types::BaseObject
    field :title, String, null: false
    field :kind, String, null: false
    field :optional, Boolean, null: false
  end
end
