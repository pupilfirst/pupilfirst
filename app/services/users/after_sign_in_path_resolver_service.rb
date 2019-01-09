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

    def after_sign_in_path(school)
      school_admin_path(school) || faculty_path || admin_path || founder_path || root_path
    end

    private

    def school_admin_path(school)
      return if @user.school_admins.find_by(school: school).blank?

      url_helpers.school_path
    end

    def faculty_path
      courses_with_review_dashboard = @user.faculty&.courses_with_dashboard
      return if courses_with_review_dashboard.blank?

      url_helpers.course_coach_dashboard_path(courses_with_review_dashboard.first)
    end

    def admin_path
      return if @user.admin_user.blank?

      url_helpers.admin_dashboard_path
    end

    def founder_path
      return if @user.founders.blank?

      url_helpers.student_dashboard_path
    end

    def root_path
      url_helpers.root_path
    end
  end
end
