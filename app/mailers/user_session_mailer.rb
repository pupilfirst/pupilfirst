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

  private

  def from
    "#{@school_name} <noreply@pupilfirst.com>"
  end

  def roadie_options_for(school)
    roadie_options.combine(
      url_options: {
        host: school.present? ? school.domains.primary.fqdn : 'www.pupilfirst.com'
      }
    )
  end
end
