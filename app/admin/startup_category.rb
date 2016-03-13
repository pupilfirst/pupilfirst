ActiveAdmin.register StartupCategory do
  menu parent: 'Startups', label: 'Categories'
  filter :name

  index do
    selectable_column

    column :name

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Details' do
      f.input :name
    end
    f.actions
  end

  permit_params :name
end
