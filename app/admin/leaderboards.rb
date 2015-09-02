ActiveAdmin.register_page 'Leaderboards' do
  menu parent: 'Startups'

  sidebar :filter_by_date do
    render 'admin/dashboard/karma_points_filter'
  end

  content do
    render 'admin/dashboard/karma_points'
  end
end
