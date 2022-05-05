class CreatePostMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :body, validates: { length: { minimum: 1, maximum: 10_000 } }
  property :topic_id, validates: { presence: true }
  property :reply_to_post_id

  validate :cannot_reply_to_topic_body

  def cannot_reply_to_topic_body
    return if reply_to_post_id.blank?

    if reply_to_post_id.present? && reply_to_post_id != topic.first_post.id
      return
    end

    errors.add(:base, 'Cannot add reply to first post')
  end

  validate :topic_is_not_locked

  def topic_is_not_locked
    return if topic.locked_at.blank?

    errors.add(:base, 'Cannot add reply to a locked topic')
  end

  def create_post
    post =
      Post.transaction do
        # Update the topic's last activity time.
        topic.update!(last_activity_at: Time.zone.now)

        Post.create!(
          creator: current_user,
          topic: topic,
          body: body,
          reply_to_post: reply_to_post,
          post_number: post_number
        )
      end

    # Send a notification mail to addressee only if she isn't replying to herself.
    if addressee.present? && current_user != addressee
      UserMailer.new_post(post, addressee).deliver_later
    end

    Notifications::CreateJob.perform_later(:post_created, current_user, post)

    post
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= topic&.community
  end

  def addressee
    reply_to_post&.creator || topic.creator
  end

  def topic
    @topic ||= Topic.find_by(id: topic_id)
  end

  def reply_to_post
    community.posts.find_by(id: reply_to_post_id)
  end

  def post_number
    topic.posts.maximum(:post_number) + 1
  end
end
