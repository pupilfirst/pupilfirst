class CoachMailer < SchoolMailer
  def course_enrollment(coach, course)
    @school = course.school
    @course = course
    @coach = coach
    @user = coach.user
    @user.regenerate_login_token

    simple_mail(
      coach.email,
      I18n.t(
        'mailers.coach.course_enrollment.subject',
        course_name: @course.name
      )
    )
  end
end
