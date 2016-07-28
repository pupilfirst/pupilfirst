ActiveAdmin.register_page 'Targets Overview' do
  controller do
    skip_after_action :intercom_rails_auto_include
  end

  menu parent: 'Targets'

  content do
    render 'target_templates_list'
  end
end
