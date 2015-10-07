ActiveAdmin.register Category do
  filter :name

  index do
    selectable_column

    column :name

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
    end
    f.actions
  end

  permit_params :name
end
