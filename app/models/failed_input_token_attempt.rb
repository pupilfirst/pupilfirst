class FailedInputTokenAttempt < ApplicationRecord
  belongs_to :authenticatable, polymorphic: true

  validates :purpose, presence: true

  enum purpose: { sign_in: "sign_in" }

  def self.log_failed_attempt(authenticatable, purpose)
    new_attempt_count =
      FailedInputTokenAttempt.where(
        authenticatable: authenticatable,
        purpose: purpose
      ).count + 1

    # When the maximum number of attempts is reached, delete matching input tokens.
    if new_attempt_count >= Settings.input_token_max_attempts
      AuthenticationToken.transaction do
        # Delete all input tokens for the same purpose.
        AuthenticationToken
          .input_token
          .where(authenticatable: authenticatable, purpose: purpose)
          .delete_all

        # Delete all the failed attempts - we don't need them anymore.
        clean_up_failed_attempts(
          authenticatable: authenticatable,
          purpose: purpose
        )
      end

      false
    else
      FailedInputTokenAttempt.create!(
        authenticatable: authenticatable,
        purpose: purpose
      )

      true
    end
  end

  def self.clean_up_failed_attempts(authenticatable: nil, purpose: nil)
    FailedInputTokenAttempt.where(
      authenticatable: authenticatable,
      purpose: purpose
    ).delete_all
  end
end
