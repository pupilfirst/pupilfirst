ActiveAdmin.register Level do
  include DisableIntercom

  menu parent: 'Targets'

  permit_params :number, :name, :description, :unlock_on

  filter :name, as: :string
  filter :number
  filter :unlock_on, label: 'Unlock Date'

  index do
    selectable_column

    column :number
    column :name
    column :unlock_on

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :number
      f.input :name
      f.input :description
      f.input :unlock_on, as: :datepicker
    end

    f.actions
  end
end
