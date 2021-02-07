class SimilarTopicsResolver < ApplicationQuery
  property :title
  property :community_id

  def similar_topics
    topics = community.topics.where('created_at > ?', 1.year.ago).search_by_title(title_for_search).limit(5)
    ActiveRecord::Precounter.new(topics).precount(:replies)
  end

  def title_for_search
    title.strip
      .gsub(/[^a-z\s0-9]/i, '')
      .split(' ').reject do |word|
      word.length < 3
    end.join(' ')[0..50]
  end

  def authorized?
    return false if community.blank?

    courses_as_student = current_user.founders.not_dropped_out.joins(:course).select(:course_id)
    return true if community.courses.exists?(id: courses_as_student)

    # Coaches and school admins have access to all communities..
    return true if current_user.faculty.present? || current_user.school_admin.present?

    false
  end

  def community
    @community ||= current_school.communities.find_by(id: community_id)
  end
end
