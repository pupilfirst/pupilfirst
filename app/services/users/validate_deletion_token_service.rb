module Users
  class ValidateDeletionTokenService
    # @param token [String] Token received via link.
    def initialize(token, current_school)
      @token = token
      @current_school = current_school
    end

    # return user with token or nil if invalid
    def authenticate
      if @token.present? && valid_request?
        user
      end
    end

    private

    def user
      @user ||= User.find_by_hashed_delete_account_token(@token) # rubocop:disable Rails/DynamicFindBy
    end

    def valid_request?
      return false if user.blank? || user.school != @current_school

      time_since_last_mail = Time.zone.now - user.delete_account_sent_at

      time_since_last_mail < 30.minutes
    end
  end
end
