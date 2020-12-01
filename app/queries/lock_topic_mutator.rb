class LockTopicMutator < ApplicationQuery
  include AuthorizeCommunityUser
  property :id, validates: { presence: true }

  def lock_topic
    topic.update!(locked_at: Time.zone.now, locked_by: current_user)
  end

  private

  alias authorized? authorized_moderate?

  def community
    topic&.community
  end

  def topic
    @topic ||= Topic.find_by(id: id)
  end
end
