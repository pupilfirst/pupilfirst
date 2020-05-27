ActiveAdmin.register Level do
  menu parent: 'Targets'

  permit_params :number, :name, :description, :unlock_on, :course_id

  filter :name, as: :string
  filter :number
  filter :course, as: :select
  filter :unlock_on, label: 'Unlock Date'

  index do
    selectable_column

    column :number
    column :name
    column :unlock_on
    column :course
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :number
      f.input :name
      f.input :description
      f.input :unlock_on, as: :datepicker
      f.input :course, as: :select
    end

    f.actions
  end
end
