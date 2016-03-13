ActiveAdmin.register Visit do
  scope :founder_visits, default: true
  scope :all

  menu parent: 'Founders'
  actions :index, :show
  config.sort_order = 'started_at_desc'

  index do
    selectable_column

    column :user
    column :user_type
    column :browser
    column :landing_page
    column :started_at

    actions
  end
end
