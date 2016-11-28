ActiveAdmin.register ProgramWeek do
  include DisableIntercom
  menu parent: 'Targets'

  permit_params :name, :number, :icon, :batch_id

  index do
    selectable_column

    column :batch
    column :number
    column :name

    actions
  end
end
