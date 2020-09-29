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
    field :creator_name, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :participants, [Types::TopicParticipantType], null: false
    field :participants_count, Int, null: false

    def creator_name
      object.first_post.creator&.name
    end

    def likes_count
      object.first_post.post_likes.count
    end

    def participants
      creator = object.first_post.creator

      limit = creator.present? ? 2 : 3

      User.where(id: creator).or(User.where(id: object.replies.pluck(:creator_id).uniq)).includes(:avatar_attachment).limit(limit)
    end

    def participants_count
      object.posts.pluck(:creator_id).uniq.count
    end

    def live_replies_count
      object.live_replies.count
    end
  end
end

