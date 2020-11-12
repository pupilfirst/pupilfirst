class StudentDetailsResolver < ApplicationQuery
  property :student_id

  def student_details
    {
      email: student.email,
      targets_completed: targets_completed,
      targets_pending_review: targets_pending_review,
      total_targets: current_course_targets.count,
      level_id: level.id,
      evaluation_criteria: evaluation_criteria,
      quiz_scores: quiz_scores,
      average_grades: average_grades,
      completed_level_ids: completed_level_ids,
      team: team,
    }
  end

  def completed_level_ids
    required_targets_by_level = Target.live.joins(:target_group).where(target_groups: { milestone: true, level_id: levels.select(:id) }).distinct(:id)
      .pluck(:id, 'target_groups.level_id').each_with_object({}) do |(target_id, level_id), required_targets_by_level|
      required_targets_by_level[level_id] ||= []
      required_targets_by_level[level_id] << target_id
    end

    passed_target_ids = TimelineEvent.joins(:founders).where(founders: { id: student.id }).where.not(passed_at: nil).distinct(:target_id).pluck(:target_id)

    levels.pluck(:id).select do |level_id|
      ((required_targets_by_level[level_id] || []) - passed_target_ids).empty?
    end
  end

  def average_grades
    @average_grades ||= TimelineEventGrade.where(timeline_event: submissions_for_grades).group(:evaluation_criterion_id).average(:grade).map do |ec_id, average_grade|
      { evaluation_criterion_id: ec_id, average_grade: average_grade.round(1) }
    end
  end

  def targets_completed
    latest_submissions.passed.distinct(:target_id).count(:target_id)
  end

  def targets_pending_review
    latest_submissions.pending_review.distinct(:target_id).count(:target_id)
  end

  def current_course_targets
    course.targets.live.joins(:level).where.not(levels: { number: 0 })
  end

  def quiz_scores
    submissions.where.not(quiz_score: nil).pluck(:quiz_score)
  end

  def course
    @course ||= student.course
  end

  def authorized?
    return false if current_user.blank?

    return false if student.blank?

    return true if current_user.id == student.user_id

    current_user.faculty.present? && current_user.faculty.courses.exists?(id: student.course)
  end

  def levels
    @levels ||= course.levels.unlocked.where('number <= ?', level.number)
  end

  def level
    @level ||= student.level
  end

  def student
    @student ||= Founder.includes(:user).find_by(id: student_id)
  end

  def team
    @team ||= student.startup
  end

  def submissions
    @submissions ||= student.timeline_events.joins(:target).where(targets: { id: current_course_targets })
  end

  def latest_submissions
    submissions.where(timeline_event_owners: { latest: true })
  end

  def submissions_for_grades
    latest_submissions.includes(:founders, :target).select { |submission| submission.target.individual_target? || (submission.founder_ids.sort == student.team_student_ids) }
  end

  def evaluation_criteria
    EvaluationCriterion.where(id: average_grades.pluck(:evaluation_criterion_id)).map do |ec|
      {
        id: ec.id,
        name: ec.name,
        max_grade: ec.max_grade,
        pass_grade: ec.pass_grade,
      }
    end
  end
end
