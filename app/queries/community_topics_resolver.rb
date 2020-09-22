class CommunityTopicsResolver < ApplicationQuery
  property :community_id
  property :topic_category_id
  property :search

  def community_topics
    if search.present?
      applicable_topics.where('topics.title ILIKE ?', "%#{search}%")
    else
      applicable_topics
    end
  end

  private

  def authorized?
    return false if current_user.blank?

    (current_user.courses & community.courses).present?
  end

  def community
    @community ||= Community.find(community_id)
  end

  def applicable_topics
    if topic_category_id.present?
      community.topics.live.where(topic_category_id: topic_category_id)
    else
      community.topics.live
    end
  end
end
