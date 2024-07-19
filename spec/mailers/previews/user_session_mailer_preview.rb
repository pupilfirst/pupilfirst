class UserSessionMailerPreview < ActionMailer::Preview
  def send_login_token
    school = School.first
    user = school.users.first

    url_options = {
      token: SecureRandom.urlsafe_base64,
      host:
        (
          if school.present?
            school.domains.primary.fqdn
          else
            "www.pupilfirst.localhost"
          end
        ),
      protocol: "https"
    }

    UserSessionMailer.send_login_token(user, url_options, "123456")
  end

  def send_reset_password_token
    school = School.first
    user = school.users.first
    user.regenerate_reset_password_token

    reset_password_url =
      Rails.application.routes.url_helpers.reset_password_url(
        token: user.original_reset_password_token,
        host:
          (
            if school.present?
              school.domains.primary.fqdn
            else
              "www.pupilfirst.localhost"
            end
          ),
        protocol: "https"
      )

    UserSessionMailer.send_reset_password_token(
      user,
      school,
      reset_password_url
    )
  end
end
