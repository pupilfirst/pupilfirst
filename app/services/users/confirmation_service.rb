module Users
  # This service should be triggered after a user successfully signs in, and it ensures that `confirmed_at` is updated.
  class ConfirmationService
    include Loggable

    def initialize(user)
      @user = user
    end

    def execute
      return if @user.confirmed?

      log "Confirming user with email #{@user.email}"

      # Save confirmed_at.
      @user.update(confirmed_at: Time.zone.now)
    end
  end
end
