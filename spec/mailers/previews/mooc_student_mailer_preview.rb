class MoocStudentMailerPreview < ActionMailer::Preview
  def welcome
    user = User.new(login_token: 'LOGIN_TOKEN')
    mooc_student = MoocStudent.new(user: user)
    MoocStudentMailer.welcome(mooc_student)
  end
end
