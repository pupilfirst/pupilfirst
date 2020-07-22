class CoachMailerPreview < ActionMailer::Preview
  def course_enrollment
    course = Course.first
    coach = course.faculty.last || Faculty.first
    coach.user.login_token = 'LOGIN_TOKEN'

    CoachMailer.course_enrollment(coach, course)
  end
end
