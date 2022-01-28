class CoachMailer < SchoolMailer
  def course_enrollment(coach, course)
    @school = course.school
    @course = course
    @coach = coach
    @user = coach.user
    @user.regenerate_login_token
    @user.update!(login_token_generated_at: Time.zone.now)

    simple_roadie_mail(
      coach.email,
      "You have been added as a coach in #{@course.name}"
    )
  end
end
