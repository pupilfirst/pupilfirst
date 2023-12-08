module Types
  class TargetDetailsType < Types::BaseObject
    field :title, String, null: false
    field :target_group_id, ID, null: false
    field :visibility, String, null: false
  end
end
