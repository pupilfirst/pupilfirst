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
end
