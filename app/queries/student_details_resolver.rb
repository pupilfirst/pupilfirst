class StudentDetailsResolver < ApplicationQuery
  property :student_id

  def student_details
    {
      name: student.name,
      title: student.title,
      email: student.email,
      avatar_url: avatar_url,
      phone: student.phone,
      coach_notes: coach_notes,
      targets_completed: targets_completed,
      total_targets: total_targets,
      level_id: level.id,
      social_links: social_links,
      evaluation_criteria: evaluation_criteria,
      quiz_scores: quiz_scores,
      average_grades: average_grades,
      levels_completed: levels_completed
    }
  end

  def levels_completed
    required_targets_by_level = Target.joins(:target_group).where(target_groups: { milestone: true, level_id: course.levels.select(:id) }).distinct(:id)
      .pluck(:id, 'target_groups.level_id').each_with_object({}) do |(target_id, level_id), required_targets_by_level|
      required_targets_by_level[level_id] ||= []
      required_targets_by_level[level_id] << target_id
    end

    passed_target_ids = TimelineEvent.joins(:founders).where(founders: { id: student.id }).where.not(passed_at: nil).distinct(:target_id).pluck(:target_id)

    course.levels.pluck(:id).select do |level_id|
      ((required_targets_by_level[level_id] || []) - passed_target_ids).empty?
    end.map(&:to_s)
  end

  def average_grades
    @average_grades ||= TimelineEventGrade.where(timeline_event: submissions).group(:evaluation_criterion_id).average(:grade).map do |ec_id, average_grade|
      { id: ec_id, average_grade: average_grade.round(1) }
    end
  end

  def targets_completed
    submissions.passed.distinct(:target_id).count
  end

  def total_targets
    course.targets.live.count
  end

  def quiz_scores
    submissions.where.not(quiz_score: nil).pluck(:quiz_score)
  end

  def course
    @course ||= student.course
  end

  def authorized?
    return false if current_user.faculty.blank?

    return false if student.blank?

    current_user.faculty.reviewable_courses.where(id: student.course).exists?
  end

  def level
    @level ||= student.level
  end

  def student
    @student ||= Founder.where(id: student_id).includes(:user).first
  end

  def avatar_url
    user = student.user
    if user.avatar.attached?
      Rails.application.routes.url_helpers.rails_representation_path(user.avatar_variant(:mid), only_path: true)
    end
  end

  def coach_notes
    CoachNote.where(student_id: student_id).includes(author: [user: { avatar_attachment: :blob }]).order('created_at DESC').limit(20)
  end

  def submissions
    student.timeline_events
  end

  def social_links
    student.user.slice('linkedin_url', 'twitter_url', 'facebook_url', 'github_url', 'personal_website_url').values - [nil]
  end

  def evaluation_criteria
    EvaluationCriterion.where(id: average_grades.pluck(:id)).map do |ec|
      {
        id: ec.id,
        name: ec.name,
        max_grade: course.max_grade,
        pass_grade: course.pass_grade
      }
    end
  end
end
