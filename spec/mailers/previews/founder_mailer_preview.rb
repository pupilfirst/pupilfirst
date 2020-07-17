class FounderMailerPreview < ActionMailer::Preview
  def enrollment
    student = Founder.last
    student.user.login_token = 'LOGIN_TOKEN'

    FounderMailer.enrollment(student)
  end
end
