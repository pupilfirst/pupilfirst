# TODO: The SchoolMailer class should be renamed to ApplicationMailer.
class SchoolMailer < ActionMailer::Base # rubocop:disable Rails/ApplicationMailer
  layout "mail/school"

  after_action :prevent_delivery_to_bounced_addresses

  protected

  def default_url_options
    primary_fqdn = @school.domains.primary.fqdn

    if primary_fqdn.blank?
      raise "School##{@school.id} does not have any primary FQDN. Cannot send email."
    end

    { host: primary_fqdn }
  end

  def from_options(enable_reply)
    options = { from: sender_signature }
    reply_to = SchoolString::EmailAddress.for(@school)
    options[:reply_to] = reply_to if reply_to.present? && enable_reply
    options
  end

  # @param email_address [String] email address to send email to
  # @param subject [String] subject of the email
  def simple_mail(email_address, subject, enable_reply: true)
    options = {
      to: email_address,
      subject: subject,
      **from_options(enable_reply)
    }

    mail(options)
  end

  private

  def prevent_delivery_to_bounced_addresses
    if BounceReport.exists?(email: mail.to)
      mail.perform_deliveries = false

      Rails.logger.info(
        "Prevented delivery of email to #{mail.to} because it is a known bounced address."
      )
    end
  end

  def school_name
    # sanitize school name to remove special characters
    @school.name.gsub(/[^\p{Alnum}\p{Space}]/, "")
  end

  def sender_signature
    custom_signature = Schools::Configuration::EmailSenderSignature.new(@school)

    if custom_signature.configured?
      "#{custom_signature.name} <#{custom_signature.email}>"
    else
      "#{school_name} <#{Settings.default_sender_email_address}>"
    end
  end
end
