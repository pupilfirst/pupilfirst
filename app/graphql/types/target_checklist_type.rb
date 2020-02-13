module Types
  class TargetChecklistType < Types::BaseObject
    field :title, String, null: false
    field :action, String, null: false
    field :optional, Boolean, null: false
  end
end
