module Users
  class ValidateUpdateEmailTokenService
    def initialize(token, current_school)
      @token = token
      @current_school = current_school
    end

    # return user with token or nil if invalid
    def authenticate
      user if @token.present? && valid_request?
    end

    private

    def user
      @user ||= User.find_by_hashed_update_email_token(@token) # rubocop:disable Rails/DynamicFindBy
    end

    def valid_request?
      return false if user.blank? || user.school != @current_school

      time_since_last_mail = Time.zone.now - user.update_email_token_sent_at

      time_since_last_mail < 30.minutes
    end
  end
end
