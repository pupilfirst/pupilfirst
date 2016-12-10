ActiveAdmin.register ProgramWeek do
  include DisableIntercom
  menu parent: 'Targets'

  permit_params :name, :number, :icon_name, :batch_id

  index do
    selectable_column

    column :batch
    column :number
    column :name

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Program Week Details' do
      f.input :batch
      f.input :name
      f.input :number
      f.input :icon_name, collection: ProgramWeek.icon_name_options
    end

    f.actions
  end
end
