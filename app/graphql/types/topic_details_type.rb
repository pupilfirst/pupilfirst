module Types
  class TopicDetailsType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :last_activity_at, GraphQL::Types::ISO8601DateTime, null: true
    field :live_replies_count, Int, null: false
    field :likes_count, Int, null: false
    field :topic_category_id, ID, null: true
    field :creator_name, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :active_users_count, Int, null: false
  end

  def creator_name
    object.first_post.creator&.name
  end
end

