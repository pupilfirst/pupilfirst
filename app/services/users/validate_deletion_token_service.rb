module Users
  class ValidateDeletionTokenService
    # @param token [String] Token received via link.
    def initialize(token, current_user)
      @token = token
      @current_user = current_user
    end

    # return user with token or nil if invalid
    def authenticate
      if @token.present? && valid_request?
        user
      end
    end

    private

    def user
      @user ||= User.find_by(delete_account_token: @token)
    end

    def valid_request?
      return false if user.blank? || @current_user.blank?

      time_since_last_mail = Time.zone.now - user.delete_account_sent_at

      user == @current_user && time_since_last_mail < 30.minutes
    end
  end
end
