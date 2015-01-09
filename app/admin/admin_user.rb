ActiveAdmin.register AdminUser do
  controller do
    newrelic_ignore
  end

  permit_params :email, :password, :password_confirmation, :fullname, :username, :avatar, :admin_type

  index do
    column :email
    column :fullname
    column :username
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :admin_type
    actions
  end

  filter :email

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :fullname
      f.input :username
      f.input :avatar, as: :file
      f.input :admin_type, as: :select, collection: AdminUser.admin_user_types 
    end
    f.actions
  end

end
