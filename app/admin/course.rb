ActiveAdmin.register Course do
  menu parent: 'Targets'

  filter :name

  permit_params :name, :ends_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :ends_at, as: :datepicker
    end
    f.actions
  end
end
