module Layouts
  class TopNavPresenter < ::ApplicationPresenter
    def links
      l = [{ title: 'Home', url: view.home_path }]
      l += [{ title: 'Admin', url: school_path }] if current_user.school_admins.where(school: current_school).exists?
      l
    end
  end
end
