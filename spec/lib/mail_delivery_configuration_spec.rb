require "rails_helper"
require Rails.root.join("lib/mail_delivery_configuration")

describe MailDeliveryConfiguration do
  let(:mailer_config) do
    Struct.new(:delivery_method, :postmark_settings, :smtp_settings).new
  end

  def configure(env)
    described_class.apply!(mailer_config, env)
  end

  it "defaults to Postmark without requiring a token during Docker asset builds" do
    configure({})

    expect(mailer_config.delivery_method).to eq(:postmark)
    expect(mailer_config.postmark_settings).to eq(api_token: nil)
  end

  it "preserves a configured Postmark token" do
    configure("POSTMARK_API_TOKEN" => "test-token")

    expect(mailer_config.postmark_settings).to eq(api_token: "test-token")
  end

  context "with SMTP" do
    let(:env) do
      {
        "MAIL_DELIVERY_METHOD" => "smtp",
        "SMTP_ADDRESS" => "mail.example.org",
        "SMTP_DOMAIN" => "example.org"
      }
    end

    it "configures STARTTLS and allows an internal relay without authentication" do
      configure(env)

      expect(mailer_config.delivery_method).to eq(:smtp)
      expect(mailer_config.smtp_settings).to include(
        address: "mail.example.org",
        port: 587,
        domain: "example.org",
        enable_starttls: true,
        enable_starttls_auto: false,
        open_timeout: 5,
        read_timeout: 10
      )
      expect(mailer_config.smtp_settings).not_to have_key(:authentication)
      expect(mailer_config.smtp_settings).not_to have_key(:tls)
    end

    it "uses implicit TLS on port 465 instead of STARTTLS" do
      configure(env.merge("SMTP_PORT" => "465"))

      expect(mailer_config.smtp_settings).to include(
        address: "mail.example.org",
        port: 465,
        tls: true,
        enable_starttls: false,
        enable_starttls_auto: false
      )
    end

    it "requires STARTTLS on alternative submission ports" do
      configure(env.merge("SMTP_PORT" => "2525"))

      expect(mailer_config.smtp_settings).to include(
        port: 2525,
        enable_starttls: true,
        enable_starttls_auto: false
      )
      expect(mailer_config.smtp_settings).not_to have_key(:tls)
    end

    it "supports authenticated SMTP with an explicit method" do
      configure(
        env.merge(
          "SMTP_PORT" => "2525",
          "SMTP_USERNAME" => "mailer",
          "SMTP_PASSWORD" => "secret",
          "SMTP_AUTHENTICATION" => "login"
        )
      )

      expect(mailer_config.smtp_settings).to include(
        port: 2525,
        user_name: "mailer",
        password: "secret",
        authentication: :login
      )
    end

    it "rejects missing or blank required settings" do
      expect { configure(env.merge("SMTP_ADDRESS" => " ")) }
        .to raise_error(ArgumentError, /SMTP_ADDRESS/)
      expect { configure(env.merge("SMTP_DOMAIN" => "")) }
        .to raise_error(ArgumentError, /SMTP_DOMAIN/)
    end

    it "rejects invalid ports" do
      %w[0 65536 invalid].each do |port|
        expect { configure(env.merge("SMTP_PORT" => port)) }
          .to raise_error(ArgumentError, /SMTP_PORT/)
      end
    end

    it "requires both SMTP credentials when either is supplied" do
      expect { configure(env.merge("SMTP_USERNAME" => "mailer")) }
        .to raise_error(ArgumentError, /SMTP_USERNAME/)
      expect { configure(env.merge("SMTP_PASSWORD" => "secret")) }
        .to raise_error(ArgumentError, /SMTP_USERNAME/)
    end

    it "rejects unsupported authentication methods and orphan settings" do
      expect do
        configure(
          env.merge(
            "SMTP_USERNAME" => "mailer",
            "SMTP_PASSWORD" => "secret",
            "SMTP_AUTHENTICATION" => "digest"
          )
        )
      end.to raise_error(ArgumentError, /SMTP_AUTHENTICATION/)

      expect { configure(env.merge("SMTP_AUTHENTICATION" => "plain")) }
        .to raise_error(ArgumentError, /SMTP_AUTHENTICATION/)
    end
  end

  it "rejects unknown mail transports rather than falling back silently" do
    expect { configure("MAIL_DELIVERY_METHOD" => "automatic") }
      .to raise_error(ArgumentError, /MAIL_DELIVERY_METHOD/)
  end
end
