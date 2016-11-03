ActiveAdmin.register User do
  include DisableIntercom

  menu parent: 'Dashboard'
  filter :email

  index do
    selectable_column

    column :email
    column :mooc_student
    column :founder

    actions
  end

  show do
    attributes_table do
      row :email
      row :mooc_student
      row :founder
    end

    panel 'Technical details' do
      attributes_table_for user do
        row :id
        row :login_token
      end
    end
  end
end
