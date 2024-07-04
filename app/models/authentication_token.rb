class AuthenticationToken < ApplicationRecord
  belongs_to :authenticatable, polymorphic: true

  validates :token, presence: true
  validates :purpose, presence: true
  validates :expires_at, presence: true

  enum token_type: {
         input_token: "input_token",
         url_token: "url_token",
         api_token: "api_token"
       }

  enum purpose: { sign_in: "sign_in" }

  scope :active, -> { where("expires_at > ?", Time.current) }

  def self.generate_input_token(authenticatable, purpose:)
    # TODO: Read expiration time from secrets.
    AuthenticationToken.create!(
      authenticatable: authenticatable,
      token: SecureRandom.random_number(100_000..999_999).to_s,
      expires_at: 10.minutes.from_now,
      token_type: "input_token",
      purpose: purpose
    )
  end

  def self.generate_url_token(authenticatable, purpose:)
    # TODO: Read expiration time from secrets.
    AuthenticationToken.create!(
      authenticatable: authenticatable,
      token: SecureRandom.urlsafe_base64,
      expires_at: 24.hours.from_now,
      token_type: "url_token",
      purpose: purpose
    )
  end

  def self.generate_tokens(authenticatable, purpose:)
    token_types =
      case purpose
      when :sign_in
        %i[input_token url_token]
      else
        raise "Unknown purpose #{purpose} for generating token."
      end

    token_types.each do |token_type|
      token =
        case token_type
        when :input_token
          SecureRandom.random_number(100_000..999_999).to_s
        when :api_token, :url_token
          SecureRandom.urlsafe_base64
        else
          raise "Unknown token type #{purpose} for generating token."
        end

      # Set expiration time based on token purpose
      # TODO: Read these from secrets.
      expires_at =
        case token_type
        when :input_token
          10.minutes.from_now
        when :url_token
          24.hours.from_now
        when :api_token
          nil
        else
          raise "Unknown token type #{purpose} for setting expiration."
        end

      # Create and return the new token record
      AuthenticationToken.create!(
        authenticatable: authenticatable,
        token: token,
        expires_at: expires_at
      )
    end
  end

  def verify_token(input_token, authenticatable: nil)
    return false if expired?

    token_to_compare =
      api_token? ? Digest::SHA2.base64digest(input_token) : input_token

    if token == token_to_compare
      handle_successful_verification
      true
    else
      log_failed_attempt(authenticatable: authenticatable)
      false
    end
  end

  def expired?
    expires_at.past?
  end

  # Handle the actions after a successful verification
  def handle_successful_verification
    destroy if input_token? || url_token?
  end

  def log_failed_attempt(authenticatable: nil)
    return if authenticatable.nil?

    FailedOtpAttempt.create!(authenticatable: authenticatable)
  end

  def self.max_attempts
    # TODO: Read this from config.
    3
  end
end
