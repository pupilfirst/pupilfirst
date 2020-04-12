class CreatePostMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :body, validates: { length: { minimum: 1, maximum: 15_000 } }
  property :topic_id, validates: { presence: true }
  property :reply_to_post_id

  def create_post
    Post.transaction do
      post = Post.create!(
        creator: current_user,
        topic: topic,
        body: body,
        reply_to_post: reply_to_post
      )

      # Send a notification mail to addressee only if she isn't replying to herself.
      UserMailer.new_post(post, addressee).deliver_later if addressee.present? && current_user != addressee

      # Update the topic's last activity time.
      topic.update!(last_activity_at: Time.zone.now)

      post
    end
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
    @topic ||= Topic.find_by(id: topic)
  end

  def reply_to_post
    community.posts.find_by(id: reply_to_post_id)
  end
end
