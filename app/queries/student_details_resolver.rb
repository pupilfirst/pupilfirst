class StudentDetailsResolver < ApplicationQuery
  property :student_id

  def student_details
    {
      title: student.title,
      email: student.email,
      phone: student.phone,
      coach_notes: coach_notes,
      submissions: submissions,
      level_id: student.level.id,
      social_links: social_links,
      evaluation_criteria: student.course.evaluation_criteria,
      grades: grades
    }
  end

  def authorized?
    return false if current_user.faculty.blank?

    current_user.faculty.reviewable_courses.where(id: student.course).exists?
  end

  def student
    @student ||= Founder.find(student_id)
  end

  def coach_notes
    CoachNote.where(student_id: student_id)
  end

  def submissions
    @submissions ||= student.timeline_events.includes(:target)
  end

  def social_links
    student.user.slice('linkedin_url', 'twitter_url', 'facebook_url', 'github_url').values - [nil]
  end

  def grades
    TimelineEventGrade.where(timeline_event_id: submissions.pluck(:id))
  end
end
