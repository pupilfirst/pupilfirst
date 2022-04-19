class UserSessionMailerPreview < ActionMailer::Preview
  def send_login_token

    # You can also check how it would look if signing in from a school.
    # school = School.find_by(name: 'SV.CO')

    # Or, a school with a logo that has transparency.
    # school = School.find_by(name: 'Hackkar')

    # Or, a school without a logo.
    # school = School.find_by(name: 'Demo')

    # host = school.present? ? school.domains.primary.fqdn : 'www.pupilfirst.localhost'
    # login_url = Rails.application.routes.url_helpers.user_token_url(token: 'LOGIN_TOKEN', host: host, protocol: 'https')
    school = School.first
    user = school.users.first
    user.regenerate_login_token
    url_options = {
      token: user.original_login_token,
      host:  school.present? ? school.domains.primary.fqdn : 'www.pupilfirst.localhost',
      protocol: 'https'
    }
    UserSessionMailer.send_login_token(user, url_options)
  end

  def send_reset_password_token
    school = School.first
    user = school.users.first
    user.regenerate_reset_password_token
    reset_password_url = Rails.application.routes.url_helpers.reset_password_url(
      token: user.original_reset_password_token,
      host: school.present? ? school.domains.primary.fqdn : 'www.pupilfirst.localhost',
      protocol: 'https'
    )
    UserSessionMailer.send_reset_password_token(user, school, reset_password_url)
  end
end
