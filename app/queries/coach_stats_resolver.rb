class CoachStatsResolver < ApplicationQuery
  property :coach_id
  property :course_id

  def coach_stats
    pending_submissions = TimelineEvent.pending_review
      .joins(founders: :startup)
      .where(startups: { id: assigned_team_ids })
      .distinct.count

    {
      reviewed_submissions: TimelineEvent.where(evaluator_id: coach_id).count,
      pending_submissions: pending_submissions
    }
  end

  def assigned_team_ids
    @assigned_team_ids ||= coach.startups.pluck(:id)
  end

  def authorized?
    current_user.school_admin.present? && course.present? && coach.present?
  end

  def course
    current_school.courses.find_by(id: course_id)
  end

  def coach
    course.faculty.find_by(id: coach_id)
  end
end
