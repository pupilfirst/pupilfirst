class StudentMailerPreview < ActionMailer::Preview
  def enrollment
    student = Founder.last
    StudentMailer.enrollment(student)
  end
end
