module ActiveAdmin::ActiveAdminHelper
  def sv_id_link(user)
    if user.present?
      link_to "#{user.email} - #{user.fullname} #{user.phone.present? ? "(#{user.phone}" : ''})", admin_user_path(user)
    else
      '<em>Missing, probably deleted.</em>'.html_safe
    end
  end

  def startup_link(startup)
    if startup.present?
      link_to startup.name, admin_startup_path(startup)
    else
      '<em>Unknown</em>'.html_safe
    end
  end
end
