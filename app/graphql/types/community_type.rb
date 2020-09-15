module Types
  class CommunityType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :target_linkable, Boolean, null: false
    field :topic_categories, [Types::TopicCategoryType], null: false
  end
end
