module Types
  class TargetChecklistType < Types::BaseObject
    field :title, String, null: false
    field :kind, String, null: true
    field :optional, Boolean, null: false
  end
end
