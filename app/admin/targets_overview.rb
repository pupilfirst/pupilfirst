ActiveAdmin.register_page 'Targets Overview' do
  menu parent: 'Targets'

  content do
    render 'target_templates_list'
  end
end
