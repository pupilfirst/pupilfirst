class UpdateTopicMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :id
  property :title, validates: { length: { minimum: 1, maximum: 250 }, allow_nil: false }
  property :topic_category_id

  def update_topic
    Topic.transaction do
      topic.update!(title: title, topic_category: topic_category)
      topic.first_post.update!(editor: current_user)
      topic
    end
  end

  private

  alias authorized? authorized_update?

  def community
    @community ||= topic&.community
  end

  def creator
    topic&.first_post&.creator
  end

  def topic
    @topic ||= Topic.find_by(id: id)
  end

  def topic_category
    return if topic_category_id.blank?

    community.topic_categories.find_by(id: topic_category_id)
  end
end
