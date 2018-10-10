ActiveAdmin.register AdminUser do
  controller do
    include DisableIntercom
  end

  menu parent: 'Dashboard'

  permit_params :email, :fullname, :avatar, :admin_type, :faculty_id

  index do
    id_column

    column :email
    column :fullname
    column :admin_type

    actions
  end

  filter :email
  filter :fullname
  filter :admin_type, as: :select, collection: -> { AdminUser.admin_user_types }

  form do |f|
    f.inputs 'Admin Details' do
      f.input :email
      f.input :fullname
      f.input :avatar, as: :file
      f.input :admin_type, as: :select, collection: AdminUser.admin_user_types
      f.input :faculty
    end
    f.actions
  end
end
