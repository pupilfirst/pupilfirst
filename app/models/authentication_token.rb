class AuthenticationToken < ApplicationRecord
  belongs_to :authenticatable, polymorphic: true

  validates :token, presence: true
  validates :expires_at, presence: true
  validates :attempt_count, presence: true

  enum token_type: {
         input_token: "input_token",
         url_token: "url_token",
         api_token: "api_token"
       }

  scope :active, -> { where("expires_at > ?", Time.current) }

  def self.generate_token(authenticatable, token_type)
    token =
      case token_type
      when :input_token
        SecureRandom.random_number(100_000..999_999).to_s
      when :api_token, :url_token
        SecureRandom.urlsafe_base64
      else
        raise "Unknown token type #{token_type} for generating token."
      end

    # Set expiration time based on token type
    expires_at =
      case token_type
      when :input_token
        10.minutes.from_now
      when :url_token
        24.hours.from_now
      when :api_token
        nil
      else
        raise "Unknown token type #{token_type} for setting expiration."
      end

    # Create and return the new token record
    AuthenticationToken.create!(
      authenticatable: authenticatable,
      token: token,
      token_type: token_type.to_s,
      expires_at: expires_at
    )
  end

  def verify_token(input_token)
    return false if expired? || attempts_exceeded?

    token_to_compare =
      api_token? ? Digest::SHA2.base64digest(input_token) : input_token

    if token == token_to_compare
      handle_successful_verification
      true
    else
      increment_attempts
      false
    end
  end

  def expired?
    expires_at <= Time.current
  end

  def attempts_exceeded?
    attempt_count >= AuthenticationToken.max_attempts
  end

  # Handle the actions after a successful verification
  def handle_successful_verification
    destroy if input_token? || url_token?
  end

  def increment_attempts
    update(attempt_count: attempt_count + 1)
  end

  def self.max_attempts
    # TODO: Read this from config.
    3
  end
end
