class UserSessionMailerPreview < ActionMailer::Preview
  def send_login_token
    school = nil

    # You can also check how it would look if signing in from a school.
    # school = School.first

    # Or, a school with a logo that has transparency.
    # school = School.second

    host = school.present? ? school.domains.first.fqdn : 'www.pupilfirst.localhost'
    login_url = Rails.application.routes.url_helpers.user_token_url(token: 'LOGIN_TOKEN', host: host, protocol: 'https')

    UserSessionMailer.send_login_token('johndoe@example.com', school, login_url)
  end
end
