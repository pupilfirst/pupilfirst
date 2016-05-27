ActiveAdmin.register ApplicationStage do
  menu parent: 'Batches'

  permit_params :name, :number, :days_before_batch, :final_stage
  config.sort_order = 'number_asc'

  index do
    selectable_column

    column :number
    column :name
    column 'Starts X days before batch', :days_before_batch
    column :final_stage

    actions
  end
end
