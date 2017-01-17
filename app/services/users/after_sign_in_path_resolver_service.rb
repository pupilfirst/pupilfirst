module Users
  # Returns path to which user is to be sent after signing in.
  #
  # This is useful for when no referer is supplied to the sign in path.
  class AfterSignInPathResolverService
    include RoutesResolvable

    def initialize(user)
      @user = user
      raise "Can only resolve paths for instances of User. Given #{resource.class}." unless @user.is_a?(User)
    end

    def after_sign_in_path
      if @user.founder.present? && @user.founder.startup.present?
        return url_helpers.dashboard_founder_path if Feature.active?(:founder_dashboard, @user.founder)
        url_helpers.startup_path(@user.founder.startup)
      elsif @user.batch_applicant.present?
        url_helpers.apply_continue_path
      elsif @user.mooc_student.present?
        url_helpers.six_ways_start_path
      else
        url_helpers.root_path
      end
    end
  end
end
