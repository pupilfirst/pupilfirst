module ActiveAdmin::ActiveAdminHelper
  def sv_id_link(user)
    link_to "#{user.email} - #{user.fullname} #{user.phone.present? ? "(#{user.phone}" : ''})", admin_user_path(user)
  end

  def startup_link(startup)
    link_to startup.name, admin_startup_path(startup)
  end
end
