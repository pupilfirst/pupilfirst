class CreateTopicSubscriptionMutator < ApplicationQuery
  include AuthorizeCommunityUser
  property :topic_id, validates: { presence: true }

  def subscribe
    TopicSubscription.create!(user: current_user, topic: topic)
  end

  private

  alias authorized? authorized_create?

  def community
    @community ||= topic&.community
  end

  def topic
    @topic ||= Topic.find_by(id: topic_id)
  end
end
