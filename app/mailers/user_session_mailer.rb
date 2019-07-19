# This mailer is responsible for sending the email with the login token. Since it needs to handle both white-labeled and
# non-white-labeled attempts to sign in, it has more custom code.
class UserSessionMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  def send_login_token(email, school, login_url)
    @school = school
    @school_name = school.present? ? school.name : 'PupilFirst'
    @login_url = login_url

    roadie_mail({ from: from, to: email, subject: "Log in to #{@school_name}" }, roadie_options_for(school)) do |format|
      format.html { render layout: school.present? ? 'mail/school' : 'mail/pupil_first' }
    end
  end

  def send_reset_password_token(email, school, reset_password_url)
    @school = school
    @school_name = school.present? ? school.name : 'PupilFirst'
    @reset_password_url = reset_password_url

    roadie_mail({ from: from, to: email, subject: "#{@school_name} account recovery" }, roadie_options_for(school)) do |format|
      format.html { render layout: school.present? ? 'mail/school' : 'mail/pupil_first' }
    end
  end

  private

  def from
    "#{@school_name} <noreply@pupilfirst.com>"
  end

  def roadie_options_for(school)
    host = if school.present?
      school.domains.primary.fqdn
    elsif Rails.env.production?
      'www.pupilfirst.com'
    else
      'www.pupilfirst.localhost'
    end

    roadie_options.combine(
      url_options: {
        host: host,
        protocol: Rails.env.production? ? 'https' : 'http'
      }
    )
  end
end
