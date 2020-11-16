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
    field :solved, Boolean, null: false

    def creator
      BatchLoader::GraphQL.for(object.id).batch do |topic_ids, loader|
        Topic.includes(first_post: :creator).where(id: topic_ids).each do |topic|
          loader.call(topic.id, topic.first_post.creator)
        end
      end

      # object.first_post.creator
    end

    def solved
      BatchLoader::GraphQL.for(object.id).batch(default_value: false) do |topic_ids, loader|
        Post.where(topic_id: topic_ids, solution: true).each do |post|
          loader.call(post.topic_id, true)
        end
      end

      # object.posts.where(solution: true).exists?
    end

    def likes_count
      BatchLoader::GraphQL.for(object.id).batch do |topic_ids, loader|
        scope = Post.where(post_number: 1, topic_id: topic_ids)
        ActiveRecord::Precounter.new(scope).precount(:post_likes)

        scope.each do |post|
          loader.call(post.topic_id, post.post_likes_count)
        end
      end

      # object.first_post.post_likes.count
    end

    def participants
      BatchLoader::GraphQL.for(object.id).batch(default_value: []) do |topic_ids, loader|
        Post.includes(:creator).where(topic_id: topic_ids).where('post_number < ?', 4).each do |post|
          loader.call(post.topic_id) { |memo| memo |= [post.creator].compact } # rubocop:disable Lint/UselessAssignment
        end
      end

      # creator_id = object.first_post.creator_id
      #
      # User.where(id: object.replies.pluck(:creator_id).uniq - [creator_id]).limit(2).includes(:avatar_attachment)
    end

    def participants_count
      BatchLoader::GraphQL.for(object.id).batch do |topic_ids, loader|
        Topic.joins(:posts).merge(Post.live)
          .where(id: topic_ids)
          .group(:id).distinct(:creator_id).count(:creator_id).each do |(topic_id, participants_count)|
          loader.call(topic_id, participants_count)
        end
      end

      # object.posts.live.pluck(:creator_id).uniq.count
    end

    def live_replies_count
      BatchLoader::GraphQL.for(object.id).batch do |topic_ids, loader|
        scope = Topic.where(id: topic_ids)
        ActiveRecord::Precounter.new(scope).precount(:live_replies)

        scope.each do |topic|
          loader.call(topic.id, topic.live_replies_count)
        end
      end

      # object.live_replies.count
    end
  end
end

