class PupilFirstMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  default from: "PupilFirst <noreply@pupilfirst.com>"

  layout 'mail/pupil_first'

  protected

  def roadie_options
    url_options = if Rails.env.production?
      { protocol: 'https', host: 'www.pupilfirst.com' }
    else
      { protocol: 'http', host: 'www.pupilfirst.localhost' }
    end

    super.merge(url_options: url_options)
  end
end
