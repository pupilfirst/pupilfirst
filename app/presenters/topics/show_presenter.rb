module Topics
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, topic)
      super(view_context)
      @topic = topic
    end

    POST_FIELDS = {
      only: %i[id body creator_id editor_id created_at updated_at post_number solution],
      include: { replies: { only: :id } }
    }.freeze

    def props
      {
        topic: topic_details,
        first_post: first_post_details,
        replies: details_of_replies,
        users: users,
        current_user_id: current_user.id,
        is_coach: current_coach.present?,
        community: community_details,
        target: linked_target
      }
    end

    def page_title
      @topic.title
    end

    private

    def topic_details
      @topic.attributes.slice('id', 'title')
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
      replies.map { |reply| reply.as_json(POST_FIELDS).merge(like_data(reply).as_json) }
    end

    def like_data(post)
      {
        total_likes: post.post_likes.count,
        liked_by_user: post.post_likes.where(user_id: current_user.id).exists?
      }
    end

    def users
      user_ids = [
        first_post.creator_id,
        first_post.editor_id,
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

    def community
      @topic.community
    end

    def community_details
      {
        id: community.id,
        name: community.name
      }
    end
  end
end
