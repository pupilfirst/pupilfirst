class CoachMailerPreview < ActionMailer::Preview
  def course_enrollment
    course = Course.first
    coach = course.faculty.last || Faculty.first
    @user = coach.user

    coach.user.regenerate_login_token

    CoachMailer.course_enrollment(coach, course)
  end

  def repeat_rejections_alert
    coach = Faculty.first

    submission =
      TimelineEvent.new(id: 123, target: coach.courses.first.targets.first)

    rejection_count = 3

    CoachMailer.repeat_rejections_alert(coach, submission, rejection_count)
  end
end
