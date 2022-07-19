class UnlockTopicMutator < ApplicationQuery
  include AuthorizeCommunityUser
  property :id, validates: { presence: true }

  def unlock_topic
    topic.update(locked_at: nil, locked_by: nil)
  end

  private

  alias authorized? authorized_update?

  def community
    topic&.community
  end

  def creator
    topic&.creator
  end

  def topic
    return @topic if defined?(@topic)

    @topic = Topic.find_by(id: id)
  end
end
