class StudentMailerPreview < ActionMailer::Preview
  def enrollment
    student = Founder.last
    student.user.login_token = 'LOGIN_TOKEN'

    StudentMailer.enrollment(student)
  end
end
