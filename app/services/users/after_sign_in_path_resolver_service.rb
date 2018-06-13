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
      faculty_path || admin_path || founder_path || mooc_student_path || root_path
    end

    private

    def faculty_path
      return if @user.faculty.blank? || @user.faculty.startups.blank?
      url_helpers.coaches_dashboard_path
    end

    def admin_path
      return if @user.admin_user.blank?
      url_helpers.admin_dashboard_path
    end

    def founder_path
      return if @user.founder&.startup.blank?
      url_helpers.student_dashboard_path
    end

    def mooc_student_path
      return if @user.mooc_student.blank?
      url_helpers.six_ways_path
    end

    def root_path
      url_helpers.root_path
    end
  end
end
