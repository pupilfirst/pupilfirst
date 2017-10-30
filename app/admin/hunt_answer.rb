ActiveAdmin.register HuntAnswer do
  menu parent: 'Admissions', label: 'Tech-Hunt Answers'
  actions :index
  config.filters = false

  index download_links: false do
    column :stage
    column :answer
    column :updated_at
  end
end
