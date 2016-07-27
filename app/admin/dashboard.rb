ActiveAdmin.register_page 'Dashboard' do
  controller do
    skip_after_action :intercom_rails_auto_include
  end

  menu priority: 1

  content do
    render 'dashboard'
  end
end
