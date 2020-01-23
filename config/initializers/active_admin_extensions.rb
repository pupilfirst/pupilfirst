require_relative '../../lib/active_admin/current_admin_user'

ActiveAdmin::BaseController.include ActiveAdmin::CurrentAdminUser

# Customize <head> for all active admin pages.
ActiveAdmin::Views::Pages::Base.class_eval do
  alias_method :original_build_active_admin_head, :build_active_admin_head

  def build_active_admin_head(*args, &block)
    original_build_active_admin_head(*args, &block)
    within(head) { render '/custom_active_admin_head' }
  end
end
