class CourseAuthorMailer < SchoolMailer
  def addition(course_author)
    @course = course_author.course
    @school = @course.school
    @user = course_author.user
    @user.regenerate_login_token
    @name = @user.preferred_name.presence || @user.name
    simple_mail(
      @user.email,
      I18n.t(
        'mailers.course_author.addition.subject',
        course_name: @course.name
      )
    )
  end
end
