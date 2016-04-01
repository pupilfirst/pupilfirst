ActiveAdmin.register Batch do
  menu parent: 'Startups'

  permit_params :name, :description, :start_date, :end_date, :batch_number, :slack_channel

  config.sort_order = 'batch_number_asc'

  index do
    selectable_column

    column :batch_number
    column :name
    column :start_date
    column :end_date
    column :slack_channel
    actions
  end
end
