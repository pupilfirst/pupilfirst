module Topics
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, topic)
      super(view_context)
      @topic = topic
    end

    POST_FIELDS = {
      only: %i[id body creator_id editor_id created_at post_number solution],
      include: { replies: { only: :id } }
    }.freeze

    def props
      {
        topic: topic_details,
        first_post: first_post_details,
        replies: details_of_replies,
        users: users,
        current_user_id: current_user.id,
        moderator: current_coach.present? || current_school_admin.present?,
        community: community_details,
        target: linked_target,
        topic_categories: topic_categories,
        subscribed: subscribed?
      }
    end

    def page_title
      @topic.title
    end

    private

    def topic_details
      @topic.attributes.slice('id', 'title', 'topic_category_id', 'locked_at', 'locked_by_id')
    end

    def topic_categories
      @community.topic_categories.map { |category| { id: category.id, name: category.name } }
    end

    def linked_target
      target = @topic.target

      return if target.blank?

      {
        id: view.policy(target).show? ? target.id : nil,
        title: target.title
      }
    end

    def first_post
      @topic.first_post
    end

    def first_post_details
      first_post.as_json(POST_FIELDS).merge(like_data(first_post).as_json)
    end

    def replies
      ActiveRecord::Precounter.new(@topic.replies.live.includes(:replies)).precount(:post_likes)
    end

    def details_of_replies
      replies.map { |reply| reply.as_json(POST_FIELDS).merge(like_data(reply).as_json).merge({ edited_at: reply.text_versions.last&.updated_at }.as_json) }
    end

    def like_data(post)
      {
        total_likes: post.post_likes.count,
        liked_by_user: post.post_likes.exists?(user_id: current_user.id)
      }
    end

    def users
      user_ids = [
        first_post.creator_id,
        first_post.editor_id,
        @topic.locked_by_id,
        replies.pluck(:creator_id),
        replies.pluck(:editor_id),
        current_user.id
      ].flatten.uniq

      User.where(id: user_ids).with_attached_avatar.includes(:faculty).map do |user|
        user.attributes.slice('id', 'name').merge(
          avatar_url: user.avatar_url(variant: :thumb),
          title: user.full_title
        )
      end
    end

    def subscribed?
      @topic.topic_subscription.exists?(user: current_user)
    end

    def community
      @community ||= @topic.community
    end

    def community_details
      {
        id: community.id,
        name: community.name
      }
    end
  end
end
