module Users
  # Returns path to which user is to be sent after signing in.
  #
  # This is useful for when no referer is supplied to the sign in path.
  class AfterSignInPathResolverService < BaseService
    def initialize(user)
      @user = user
      raise "Can only resolve paths for instances of User. Given #{resource.class}." unless @user.is_a?(User)
    end

    def after_sign_in_path
      if @user.founder.present? && current_founder.startup.present?
        url_helpers.startup_path(current_founder.startup)
      elsif @user.mooc_student.present?
        url_helpers.six_ways_start_path
      else
        url_helpers.root_path
      end
    end
  end
end
