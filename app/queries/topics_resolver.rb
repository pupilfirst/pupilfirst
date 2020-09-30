class TopicsResolver < ApplicationQuery
  property :community_id
  property :topic_category_id
  property :target_id
  property :search

  def topics
    if search.present?
      applicable_topics.search_by_title(title_for_search)
    else
      applicable_topics
    end.includes(first_post: { creator: :avatar_attachment })
  end

  private

  def authorized?
    return false if current_user.blank? || community.blank?

    return false if community.school_id != current_school.id

    course_ids = ([current_user.faculty&.course_ids] + [current_user.course_ids]).flatten

    (course_ids & community.course_ids).present? || current_school_admin.present?
  end

  def title_for_search
    search.strip
      .gsub(/[^a-z\s0-9]/i, '')
      .split(' ').reject do |word|
      word.length < 3
    end.join(' ')[0..50]
  end

  def community
    @community ||= Community.find_by(id: community_id)
  end

  def applicable_topics
    by_category =
      if topic_category_id.present?
        community.topics.live.where(topic_category_id: topic_category_id)
      else
        community.topics.live
      end

    if target_id.present?
      by_category.where(target_id: target_id)
    else
      by_category
    end.order('created_at DESC')
  end
end
