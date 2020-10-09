class TopicsResolver < ApplicationQuery
  property :community_id
  property :topic_category_id
  property :target_id
  property :search
  property :resolution

  def topics
    if search.present?
      applicable_topics.search_by_title(title_for_search)
    else
      applicable_topics
    end
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

  def filter_by_solution(topics, resolution)
    topics_with_solution = topics.joins(:posts).where(posts: { solution: true })
    case resolution
    when 'Solved'
      topics_with_solution
    when 'Unsolved'
      topics.where.not(id: topics_with_solution)
    else
      topics
    end
  end

  def applicable_topics
    by_solution = filter_by_solution(community.topics.live, resolution)

    by_category =
      if topic_category_id.present?
        by_solution.where(topic_category_id: topic_category_id)
      else
        by_solution
      end

    if target_id.present?
      by_category.where(target_id: target_id)
    else
      by_category
    end.order('topics.created_at DESC')
  end
end
