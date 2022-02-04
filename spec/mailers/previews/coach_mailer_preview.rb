class CoachMailerPreview < ActionMailer::Preview
  def course_enrollment
    course = Course.first
    coach = course.faculty.last || Faculty.first
    @user = coach.user

    coach.user.regenerate_login_token

    CoachMailer.course_enrollment(coach, course)
  end
end
