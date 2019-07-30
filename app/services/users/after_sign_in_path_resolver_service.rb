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
      school_admin_path || home_path || course_author_path
    end

    private

    def school_admin_path
      return if @user.school_admin.blank?

      url_helpers.school_path
    end

    def home_path
      return if @user.faculty.blank? && @user.founders.blank?

      url_helpers.home_path
    end

    def course_author_path
      url_helpers.curriculum_school_course_path(@user.course_authors.first.course)
    end
  end
end
