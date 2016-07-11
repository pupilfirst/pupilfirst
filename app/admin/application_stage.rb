ActiveAdmin.register ApplicationStage do
  menu parent: 'Admissions'

  permit_params :name, :number, :final_stage
  config.sort_order = 'number_asc'

  index do
    selectable_column

    column :number

    column :name do |application_stage|
      span application_stage.name
      em ' (Final Stage)' if application_stage.final_stage?
    end

    actions
  end
end
