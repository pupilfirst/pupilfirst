class StudentMailerPreview < ActionMailer::Preview
  def enrollment
    student = Student.last
    StudentMailer.enrollment(student)
  end
end
