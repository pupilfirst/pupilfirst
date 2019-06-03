module Types
  class TargetType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :role, String, null: false
    field :target_action_type, String, null: false
    field :visibility, String, null: false
  end
end
