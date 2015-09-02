ActiveAdmin.register_page 'Leaderboards' do
  menu parent: 'Startups'

  content do
    render 'admin/dashboard/karma_points'
  end
end
