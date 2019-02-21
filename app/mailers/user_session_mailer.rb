# This mailer is responsible for sending the email with the login token. Since it needs to handle both white-labeled and
# non-white-labeled attempts to sign in, it has more custom code.
class UserSessionMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  def send_login_token(email, school, login_url)
    @school = school&.name || 'PupilFirst'
    @login_url = login_url

    roadie_mail({ to: email, subject: "Log in to #{school_name}" }, roadie_options_for(school)) do |format|
      format.html { render layout: school.present? ? 'mail/school' : 'mail/pupil_first' }
    end
  end

  private

  def roadie_options_for(school)
    host, from = if school.present?
      ["https://#{school.domains.first.fqdn}", "#{school.name} <noreply@pupilfirst.com>"]
    else
      ['https://www.pupilfirst.com', 'PupilFirst <noreply@pupilfirst.com>']
    end

    roadie_options.combine(
      url_options: {
        host: host,
        from: from
      }
    )
  end
end
