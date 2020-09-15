module Types
  class TopicCategoryType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :topics_count, Int, null: false

    def topics_count
      object.topics.count
    end
  end
end
