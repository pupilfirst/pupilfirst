ActiveAdmin.register_page 'Key Numbers' do
  menu parent: 'Statistics'

  content do
    render 'admin/statistics/key_numbers'
  end
end
