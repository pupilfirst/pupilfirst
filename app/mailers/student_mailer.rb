class StudentMailer < SchoolMailer
  def enrollment(student)
    @school = student.course.school
    @course = student.course
    @student = student
    @user = student.user
    @user.regenerate_login_token

    simple_mail(
      @student.email,
      I18n.t(
        "mailers.student.enrollment.subject",
        name: @student.name,
        school_name: @school.name
      )
    )
  end
end
