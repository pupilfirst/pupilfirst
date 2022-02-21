class CourseAuthorMailer < SchoolMailer
  def addition(course_author)
    @course = course_author.course
    @school = @course.school
    @user = course_author.user
    @user.regenerate_login_token

    simple_mail(
      @user.email,
      "You have been added as an author in #{@course.name}"
    )
  end
end
