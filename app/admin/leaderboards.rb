ActiveAdmin.register_page 'Leaderboards' do
  menu parent: 'Startups'

  sidebar :filter_by_batch_and_date do
    render 'admin/leaderboards/karma_points_filter'
  end

  content do
    render 'admin/leaderboards/karma_points'
  end
end
