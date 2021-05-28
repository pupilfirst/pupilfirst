class UserSessionMailerPreview < ActionMailer::Preview
  def send_login_token
    school = nil

    # You can also check how it would look if signing in from a school.
    # school = School.find_by(name: 'SV.CO')

    # Or, a school with a logo that has transparency.
    # school = School.find_by(name: 'Hackkar')

    # Or, a school without a logo.
    # school = School.find_by(name: 'Demo')

    user = Founder.last.user
    UserSessionMailer.send_login_token(user, school)
  end

  def set_first_password_token
    school = School.first
    user = school.users.first
    first_password_url = 'https://example.com/password_url'

    UserSessionMailer.set_first_password_token(user, school, first_password_url)
  end

  def send_reset_password_token
    school = School.first
    email = school.users.first.email
    reset_password_url = 'https://example.com/reset_password_url'

    UserSessionMailer.send_reset_password_token(email, school, reset_password_url)
  end
end
