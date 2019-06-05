class CommunitiesResolver < ApplicationResolver
  def member(id)
    if current_coach.present?
      current_school.communities.find(id)
    elsif current_user.present?
      community_ids = current_user.founders.joins(course: :school).where(schools: { id: current_school }).pluck('courses.community_id').compact

      Community.find(id) if id.in?(community_ids)
    else
      raise 'Not authorized'
    end
  end
end
