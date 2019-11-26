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
      level_id: student.level.id,
      social_links: social_links,
      evaluation_criteria: evaluation_criteria,
      quiz_scores: quiz_scores,
      average_grades: average_grades
    }
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
    CoachNote.where(student_id: student_id).limit(20)
  end

  def submissions
    student.timeline_events
  end

  def social_links
    student.user.slice('linkedin_url', 'twitter_url', 'facebook_url', 'github_url').values - [nil]
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
