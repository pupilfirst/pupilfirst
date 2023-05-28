class StudentMailerPreview < ActionMailer::Preview
  def enrollment
    student = Student.last
    student.user.regenerate_login_token
    StudentMailer.enrollment(student)
  end
end
