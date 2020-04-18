class UpdateTopicMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :id
  property :title, validates: { length: { minimum: 1, maximum: 250 }, allow_nil: false }

  def update_topic
    Topic.transaction do
      topic.update!(title: title)
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
end
