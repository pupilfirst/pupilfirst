module Layouts
  class TopNavPresenter < ::ApplicationPresenter
    def links
      l = current_user.present? ? [{ title: 'Dashboard', url: view.dashboard_path }] : []
      l += [{ title: 'Admin', url: view.school_path }] if current_user.present? && current_user.school_admin.present?
      l
    end
  end
end
