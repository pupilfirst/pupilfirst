ActiveAdmin.register Course do
  controller do
    include DisableIntercom
  end

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
