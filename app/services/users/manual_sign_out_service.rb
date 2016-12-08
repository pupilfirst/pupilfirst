module Users
  class ManualSignOutService
    attr_reader :controller

    delegate :session, :sign_out, to: :controller

    def initialize(controller, current_user)
      @controller = controller
      @current_user = current_user
      @signed_out = false
    end

    def sign_out_if_required
      return if @current_user&.sign_out_at_next_request.blank?

      # Set signed out at as now if this is a new sign in attempt, so that he'll be signed out a week from 'now' if
      # the flag is still set.
      session[:signed_out_at] = Time.now.to_i if @current_user.current_sign_in_at > 30.seconds.ago

      signed_out_at = session[:signed_out_at].present? ? Time.at(session[:signed_out_at].to_i) : Time.at(0)

      # Do not sign out the user again if he was signed out using this method less than a week ago.
      return if signed_out_at > 1.week.ago

      sign_out @current_user
      session[:signed_out_at] = Time.now.to_i
      @signed_out = true
    end

    def signed_out?
      @signed_out
    end
  end
end
