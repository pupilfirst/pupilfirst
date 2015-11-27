ActiveAdmin.register Batch do
  menu parent: 'Startups'

  permit_params :name, :description, :start_date, :end_date

  config.sort_order = 'start_date_desc'

  index do
    selectable_column
    column :name
    column :start_date
    column :end_date
    actions
  end
end
