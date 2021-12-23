class StudentMailerPreview < ActionMailer::Preview
  def enrollment
    student = Founder.last
    student.user.regenerate_login_token
    StudentMailer.enrollment(student)
  end
end
