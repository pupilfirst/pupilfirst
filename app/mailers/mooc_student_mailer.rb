class MoocStudentMailer < ApplicationMailer
  def welcome(mooc_student)
    @mooc_student = mooc_student
    mail(to: @mooc_student.email, subject: "Welcome to SV.CO's SixWays MOOC")
  end
end
