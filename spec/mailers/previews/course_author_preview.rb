class CourseAuthorPreview < ActionMailer::Preview
  def addition
    course_author = CourseAuthor.first
    course_author.user.login_token = 'LOGIN_TOKEN'

    CourseAuthorMailer.addition(course_author)
  end
end
