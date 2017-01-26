module ActiveAdmin
  module CurrentAdminUser
    extend ActiveSupport::Concern

    def current_admin_user
      @current_admin_user ||= current_user&.admin_user
    end

    def authenticate_admin_user!
      authenticate_user!
      return if current_admin_user.present?
      flash[:notice] = 'You are not an administrator!'
      redirect_to root_url
    end
  end
end
