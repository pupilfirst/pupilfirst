class DeleteTopicSubscriptionMutator < ApplicationQuery
  property :topic_id, validates: { presence: true }

  def delete_subscription
    topic_subscription.destroy
  end

  def authorized?
    current_user.present? && topic_subscription.present?
  end

  private

  def topic_subscription
    @topic_subscription ||= topic&.topic_subscription&.where(user: current_user)&.first
  end

  def topic
    @topic ||= Topic.find_by(id: topic_id)
  end
end
