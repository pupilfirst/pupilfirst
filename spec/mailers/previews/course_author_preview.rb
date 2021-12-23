class CourseAuthorPreview < ActionMailer::Preview
  def addition
    course_author = CourseAuthor.first
    course_author.user.regenerate_login_token

    CourseAuthorMailer.addition(course_author)
  end
end
