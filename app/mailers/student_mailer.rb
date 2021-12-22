class StudentMailer < SchoolMailer
  def enrollment(student)
    @school = student.course.school
    @course = student.course
    @student = student
    @user = student.user
    @user.regenerate_login_token
    @user.update!(login_mail_sent_at: Time.zone.now)

    simple_roadie_mail(
      @student.email,
      "You have been added as a student in #{@school.name}"
    )
  end
end
