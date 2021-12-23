class CoachMailerPreview < ActionMailer::Preview
  def course_enrollment
    course = Course.first
    coach = course.faculty.last || Faculty.first
    @user = coach.user

    coach.user.login_token_digest = 'LOGIN_TOKEN'

    CoachMailer.course_enrollment(coach, course)
  end
end
