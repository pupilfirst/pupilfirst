class PupilFirstMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  default from: "PupilFirst <noreply@pupilfirst.com>"

  layout 'mail/pupil_first'

  protected

  def roadie_options
    super.merge(url_options: { protocol: 'https', host: 'www.pupilfirst.com' })
  end
end
