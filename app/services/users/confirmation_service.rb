module Users
  # This service should be triggered after a user successfully signs in, and it ensures that a timeline event marking
  # confirmation exists and that `confirmed_at` is updated.
  class ConfirmationService
    include Loggable

    def initialize(user)
      @user = user
    end

    def execute
      return if @user.confirmed?

      log "Confirming user with email #{@user.email}"

      # Create a timeline event for corresponding target if user is a startup founder.
      if @user.founder&.startup.present?
        Admissions::CompleteTargetService.new(@user.founder, Target::KEY_ADMISSIONS_FOUNDER_EMAIL_VERIFICATION).execute
      end

      # Save confirmed_at.
      @user.update(confirmed_at: Time.zone.now)
    end
  end
end
