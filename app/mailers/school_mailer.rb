class SchoolMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  layout 'mail/school'

  protected

  def default_url_options
    { host: @school.domains.primary.fqdn }
  end

  def from_options
    options = { from: "#{@school.name} <noreply@pupilfirst.com>" }
    reply_to = SchoolString::EmailAddress.for(@school)
    options[:reply_to] = reply_to if reply_to.present?
    options
  end

  def roadie_options_for_school
    host_options = default_url_options.merge(protocol: Rails.env.production? ? 'https' : 'http')

    roadie_options.combine(url_options: host_options)
  end

  # @param email_address [String] email address to send email to
  # @param subject [String] subject of the email
  def simple_roadie_mail(email_address, subject)
    roadie_mail(
      {
        to: email_address,
        subject: subject,
        **from_options
      },
      roadie_options_for_school
    )
  end
end
