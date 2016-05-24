ActiveAdmin.register ApplicationStage do
  menu parent: 'Batches'

  permit_params :name, :number, :days_before_batch
  config.sort_order = 'number_asc'

  index do
    selectable_column

    column :number
    column :name
    column 'Starts X days before batch', :days_before_batch

    actions
  end
end
