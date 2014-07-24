module ActiveAdmin::ActiveAdminHelper
  def name_link(user)
    link_to "#{user.fullname} (#{user.phone.present? ? user.phone : user.email})", admin_user_path(user)
  end

  def startup_link(startup)
    link_to startup.name, admin_startup_path(startup)
  end
end
