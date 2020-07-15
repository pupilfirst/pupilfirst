# TODO: The SchoolMailer class should be renamed to ApplicationMailer.
class SchoolMailer < ActionMailer::Base # rubocop:disable Rails/ApplicationMailer
  include Roadie::Rails::Mailer

  layout 'mail/school'

  protected

  def default_url_options
    primary_fqdn = @school.domains.primary.fqdn

    raise "School##{@school.id} does not have any primary FQDN. Cannot send email." if primary_fqdn.blank?

    { host: primary_fqdn }
  end

  def from_options(enable_reply)
    options = { from: sender_signature }
    reply_to = SchoolString::EmailAddress.for(@school)
    options[:reply_to] = reply_to if reply_to.present? && enable_reply
    options
  end

  def roadie_options_for_school
    host_options = default_url_options.merge(protocol: Rails.env.production? ? 'https' : 'http')

    roadie_options.combine(url_options: host_options)
  end

  # @param email_address [String] email address to send email to
  # @param subject [String] subject of the email
  def simple_roadie_mail(email_address, subject, enable_reply: true)
    options = { to: email_address, subject: subject, **from_options(enable_reply) }

    if Rails.env.test?
      mail(options)
    else
      roadie_mail(
        options,
        roadie_options_for_school
      )
    end
  end

  private

  def school_name
    # sanitize school name to remove special characters
    @school.name.gsub(/[^0-9A-Za-z ]/, '')
  end

  def sender_signature
    custom_signature = @school.configuration['email_sender_signature']

    if custom_signature.present? && custom_signature['confirmed_at'].present?
      "#{custom_signature['name']} <#{custom_signature['email']}>"
    else
      "#{school_name} <#{Rails.application.secrets.default_sender_email_address}>"
    end
  end
end
