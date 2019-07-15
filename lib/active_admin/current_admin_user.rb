module ActiveAdmin
  module CurrentAdminUser
    extend ActiveSupport::Concern

    included do
      helper_method :current_admin_user
    end

    def current_admin_user
      @current_admin_user ||= AdminUser.where(email: true_user&.email).first
    end

    def authenticate_admin_user!
      authenticate_user!
      return if current_admin_user.present?

      flash[:notice] = 'You are not an administrator!'
      redirect_to root_url
    end
  end
end
