ActiveAdmin.register Visit do
  controller do
    include DisableIntercom
  end

  scope :user_visits, default: true
  scope :all

  menu parent: 'Founders'
  actions :index, :show
  config.sort_order = 'started_at_desc'

  filter :user_type
  filter :started_at

  index do
    selectable_column

    column :user
    column :browser
    column :landing_page
    column :os
    column :device_type
    column :started_at

    actions
  end
end
