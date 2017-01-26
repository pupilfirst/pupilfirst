require_relative '../../lib/active_admin/current_admin_user'

ActiveAdmin::BaseController.send(:include, ActiveAdmin::CurrentAdminUser)
