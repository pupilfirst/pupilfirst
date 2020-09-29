module Types
  class TopicType < Types::BaseObject
    connection_type_class Types::PupilfirstConnection

    field :id, ID, null: false
    field :title, String, null: false
    field :last_activity_at, GraphQL::Types::ISO8601DateTime, null: true
    field :live_replies_count, Int, null: false
    field :likes_count, Int, null: false
    field :views, Int, null: false
    field :topic_category_id, ID, null: true
    field :creator, Types::UserType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :participants, [Types::UserType], null: false
    field :participants_count, Int, null: false

    def creator
      object.first_post.creator
    end

    def likes_count
      object.first_post.post_likes.count
    end

    def participants
      creator_id = object.first_post.creator_id

      User.where(id: object.replies.pluck(:creator_id).uniq - [creator_id]).limit(2).includes(:avatar_attachment)
    end

    def participants_count
      object.posts.live.pluck(:creator_id).uniq.count
    end

    def live_replies_count
      object.live_replies.count
    end
  end
end

