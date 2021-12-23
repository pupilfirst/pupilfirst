class CourseAuthorPreview < ActionMailer::Preview
  def addition
    course_author = CourseAuthor.first
    p course_author
    course_author.user.login_token_digest = 'LOGIN_TOKEN'

    CourseAuthorMailer.addition(course_author)
  end
end
