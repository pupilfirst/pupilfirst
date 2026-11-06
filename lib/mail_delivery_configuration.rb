# Configure the production email transport using Rails Action Mailer.
# Postmark remains the default so existing deployments and Docker asset builds
# do not require new environment variables.
module MailDeliveryConfiguration
  AUTHENTICATION_METHODS = %w[plain login cram_md5].freeze

  def self.apply!(action_mailer, env = ENV)
    case env.fetch("MAIL_DELIVERY_METHOD", "postmark")
    when "postmark"
      action_mailer.delivery_method = :postmark
      # Deliberately use [] instead of fetch: assets:precompile boots in
      # production mode without a Postmark credential.
      action_mailer.postmark_settings = {
        api_token: env["POSTMARK_API_TOKEN"]
      }
    when "smtp"
      action_mailer.delivery_method = :smtp
      action_mailer.smtp_settings = smtp_settings(env)
    else
      raise ArgumentError, "MAIL_DELIVERY_METHOD must be postmark or smtp"
    end
  end

  def self.smtp_settings(env)
    address = required_value(env, "SMTP_ADDRESS")
    domain = required_value(env, "SMTP_DOMAIN")

    port =
      begin
        Integer(env.fetch("SMTP_PORT", "587"), 10)
      rescue ArgumentError, TypeError
        raise ArgumentError, "SMTP_PORT must be a valid integer"
      end
    unless (1..65_535).cover?(port)
      raise ArgumentError, "SMTP_PORT must be between 1 and 65535"
    end

    username = env["SMTP_USERNAME"].to_s.strip
    password = env["SMTP_PASSWORD"].to_s
    has_username = username.present?
    has_password = password.present?

    unless has_username == has_password
      raise ArgumentError, "SMTP_USERNAME and SMTP_PASSWORD must be set together"
    end

    settings = {
      address: address,
      port: port,
      domain: domain,
      # Port 465 uses implicit TLS; other ports require STARTTLS.
      enable_starttls: port != 465,
      enable_starttls_auto: false,
      open_timeout: 5,
      read_timeout: 10
    }
    settings[:tls] = true if port == 465

    if has_username
      authentication = env.fetch("SMTP_AUTHENTICATION", "plain")
      unless AUTHENTICATION_METHODS.include?(authentication)
        raise ArgumentError, "Unsupported SMTP_AUTHENTICATION"
      end

      settings.merge!(
        user_name: username,
        password: password,
        authentication: authentication.to_sym
      )
    elsif env["SMTP_AUTHENTICATION"].present?
      raise ArgumentError, "SMTP_AUTHENTICATION requires SMTP credentials"
    end

    settings
  end

  def self.required_value(env, key)
    value = env[key].to_s.strip
    raise ArgumentError, "#{key} is required for SMTP" if value.empty?

    value
  end

  private_class_method :smtp_settings, :required_value
end
