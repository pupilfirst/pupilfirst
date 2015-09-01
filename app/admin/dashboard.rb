ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1

  content do
    render 'admin/dashboard/karma_points'
  end
end
