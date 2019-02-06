ActiveAdmin.register AdminUser do
  controller do
    include DisableIntercom
  end

  menu parent: 'Dashboard'

  permit_params :fullname, :admin_type, :faculty_id

  index do
    id_column

    column :email
    column :fullname
    column :admin_type

    actions
  end

  filter :user_email, as: :string
  filter :fullname
  filter :admin_type, as: :select, collection: -> { AdminUser.admin_user_types }

  form do |f|
    f.inputs 'Admin Details' do
      f.input :fullname
      f.input :admin_type, as: :select, collection: AdminUser.admin_user_types
      f.input :faculty
    end
    f.actions
  end
end
