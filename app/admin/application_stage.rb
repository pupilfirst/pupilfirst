ActiveAdmin.register ApplicationStage do
  menu parent: 'Batches'

  permit_params :name, :number
  config.sort_order = 'number_asc'

  index do
    selectable_column

    column :name
    column :number

    actions
  end
end
