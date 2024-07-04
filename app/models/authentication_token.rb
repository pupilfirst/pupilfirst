class AuthenticationToken < ApplicationRecord
  belongs_to :authenticatable, polymorphic: true

  validates :token, presence: true
  validates :purpose, presence: true
  validates :expires_at, presence: true

  enum token_type: {
         input_token: "input_token",
         url_token: "url_token",
         hashed_token: "hashed_token"
       }

  enum purpose: { sign_in: "sign_in", use_api: "use_api" }

  scope :active, -> { where("expires_at > ?", Time.current) }

  attr_reader :original_token

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

  def self.generate_hashed_token(authenticatable, purpose:)
    @original_token = SecureRandom.urlsafe_base64

    # TODO: Read expiration time from secrets.
    AuthenticationToken.create!(
      authenticatable: authenticatable,
      token: Digest::SHA2.base64digest(@original_token),
      expires_at: nil,
      token_type: "hashed_token",
      purpose: purpose
    )
  end

  def self.verify_token(input_token, authenticatable: nil, purpose: nil)
    token_to_compare =
      (
        if purpose == "use_api"
          Digest::SHA2.base64digest(input_token)
        else
          input_token
        end
      )

    authentication_token =
      if authenticatable.blank? || purpose.blank?
        find_by(token: token_to_compare)
      else
        find_by(
          authenticatable: authenticatable,
          purpose: purpose,
          token: token_to_compare
        )
      end

    if authentication_token.blank? || authentication_token.expired?
      log_failed_attempt(authenticatable: authenticatable, purpose: purpose)
      false
    else
      handle_successful_verification
      true
    end
  end

  def expired?
    expires_at.past?
  end

  # Handle the actions after a successful verification
  def handle_successful_verification
    destroy if input_token? || url_token?
  end

  def self.log_failed_attempt(authenticatable: nil, purpose: nil)
    return if authenticatable.nil? || purpose.nil?

    # When the maximum number of attempts is reached, delete matching input tokens.
    if FailedInputTokenAttempt.where(
         authenticatable: authenticatable,
         purpose: purpose
       ).count >= AuthenticationToken.max_input_token_attempts
      AuthenticationToken.transaction do
        # Delete all input tokens for the same purpose.
        AuthenticationToken
          .input_token
          .where(authenticatable: authenticatable, purpose: purpose)
          .delete_all

        # Delete all the failed attempts - we don't need them anymore.
        FailedInputTokenAttempt.where(
          authenticatable: authenticatable,
          purpose: purpose
        ).delete_all
      end
    else
      FailedInputTokenAttempt.create!(
        authenticatable: authenticatable,
        purpose: purpose
      )
    end
  end

  def self.max_input_token_attempts
    # TODO: Read this from config.
    3
  end
end
