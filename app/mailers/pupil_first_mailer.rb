class PupilFirstMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  layout 'mail/pupil_first'

  protected

  def roadie_options
    super.merge(
      url_options: {
        host: 'https://www.pupilfirst.com',
        from: "PupilFirst <noreply@pupilfirst.com>"
      }
    )
  end
end
