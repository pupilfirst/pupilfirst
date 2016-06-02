ActiveAdmin.register Visit do
  scope :founder_visits, default: true
  scope :all

  menu parent: 'Founders'
  actions :index, :show
  config.sort_order = 'started_at_desc'

  filter :founder_startup_batch_id_eq, as: :select, collection: proc { Batch.all }, label: 'Batch'
  filter :user_type
  filter :founder
  filter :started_at

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
