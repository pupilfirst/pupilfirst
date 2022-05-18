class CourseAuthorMailer < SchoolMailer
  def addition(course_author)
    @course = course_author.course
    @school = @course.school
    @user = course_author.user
    @user.regenerate_login_token

    simple_mail(
      @user.email,
      I18n.t(
        'mailers.course_author.addition.subject',
        course_name: @course.name
      )
    )
  end
end
