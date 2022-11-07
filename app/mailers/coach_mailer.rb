class CoachMailer < SchoolMailer
  def course_enrollment(coach, course)
    @school = course.school
    @course = course
    @coach = coach

    simple_mail(
      coach.email,
      I18n.t(
        'mailers.coach.course_enrollment.subject',
        course_name: @course.name
      )
    )
  end

  def repeat_rejections_alert(coach, submission, rejection_count)
    @course = submission.target.course
    @school = @course.school
    @coach = coach
    @submission = submission
    @rejection_count = rejection_count

    simple_mail(
      coach.email,
      I18n.t(
        'mailers.coach.repeat_rejections_alert.subject',
        course_name: @course.name,
        rejection_count: rejection_count
      )
    )
  end
end
