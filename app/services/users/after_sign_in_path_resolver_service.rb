module Users
  # Returns path to which user is to be sent after signing in.
  #
  # This is useful for when no referer is supplied to the sign in path.
  class AfterSignInPathResolverService
    include RoutesResolvable

    def initialize(user, current_school)
      @user = user
      @current_school = current_school
      raise "Can only resolve paths for instances of User. Given #{resource.class}." unless @user.is_a?(User)
    end

    def after_sign_in_path
      faculty_path || admin_path || founder_path || exited_founder_path || root_path
    end

    private

    def faculty_path
      faculty = @user.faculty.find_by(school: @current_school)

      return if faculty.blank?

      courses_with_review_dashboard = faculty.courses_with_dashboard

      return if courses_with_review_dashboard.blank?

      url_helpers.course_coach_dashboard_path(courses_with_review_dashboard.first)
    end

    def admin_path
      return if @user.admin_user.blank?

      url_helpers.admin_dashboard_path
    end

    def founder_path
      return if @user.founders.not_exited.blank?

      url_helpers.student_dashboard_path
    end

    def exited_founder_path
      exited_founder = @user.founders.where(exited: true).first
      return if exited_founder.blank?

      url_helpers.student_path(exited_founder)
    end

    def root_path
      url_helpers.root_path
    end
  end
end
