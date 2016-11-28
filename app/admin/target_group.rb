ActiveAdmin.register TargetGroup do
  include DisableIntercom
  menu parent: 'Targets'

  permit_params :name, :description, :program_week_id

  index do
    selectable_column

    column :program_week
    column :name
    column :description

    actions
  end
end
