class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def raise_not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  # Sets whodunnit field for paper trail version entries.
  # @see https://github.com/gregbell/active_admin/wiki/Auditing-via-paper_trail-(change-history) Auditing using Paper Trail
  def user_for_paper_trail
    if current_user
      "#{current_user.fullname} (User##{current_user.id})"
    elsif current_admin_user
      "#{current_admin_user.email} (AdminUser##{current_admin_user.id})"
    else
      'Unknown User'
    end
  end

  def after_sign_in_path_for(resource)
    referer = session.delete :referer
    referer ? referer : super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation).concat [:avatar, :twitter_url, :linkedin_url, :username]
    # TODO
    # Unpermitted parameters: salutation, fullname, born_on(1i), born_on(2i), born_on(3i), is_student, college, course, semester
    devise_parameter_sanitizer.for(:sign_up).concat [:salutation, :fullname, :born_on, :is_student, :college_id, :course, :semester]
    devise_parameter_sanitizer.for(:accept_invitation).concat [:salutation, :fullname, :email, :born_on, :is_student, :college_id, :course, :semester, :startup, :accept_startup]
  end

end
