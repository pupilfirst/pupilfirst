module Types
  class CommunityType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :target_linkable, Boolean, null: false
    field :topic_categories, [Types::TopicCategoryType], null: false
    field :course_ids, [String], null: false

    def course_ids
      object.course_ids.map(&:to_s)
    end
  end
end
