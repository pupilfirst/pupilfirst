ActiveAdmin.register BatchApplication do
  menu parent: 'Batches', label: 'Applications', priority: 0

  permit_params :batch_id, :application_stage_id, :university_id, :product_name, :team_achievement

  # index do
  #   selectable_column
  #
  #   column :name
  #   column :number
  #
  #   actions
  # end
end
