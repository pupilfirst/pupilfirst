ActiveAdmin.register User do
  menu parent: 'Dashboard'
  filter :email

  index do
    selectable_column

    column :name
    column :phone
    column :university

    actions
  end

  show do
    attributes_table do
      row :email
      row :name
      row :phone
      row :university
    end
  end
end
