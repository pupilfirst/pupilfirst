class SchoolMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  layout 'mail/school'

  helper_method :host_options

  protected

  def host_options
    {
      host: @school.domains.primary.fqdn,
      protocol: Rails.env.production? ? 'https' : 'http'
    }
  end

  def from_options
    options = { from: "#{@school.name} <noreply@pupilfirst.com>" }
    reply_to = @school.school_strings.find_by(key: SchoolString::KEYS[:school_email_address])&.value
    options[:reply_to] = reply_to if reply_to.present?
    options
  end

  def roadie_options_for_school
    roadie_options.combine(url_options: host_options)
  end
end
