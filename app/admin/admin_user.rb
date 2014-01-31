ActiveAdmin.register AdminUser do
  controller do
    newrelic_ignore
  end

  permit_params :email, :password, :password_confirmation, :fullname, :username, :avatar

  index do
    column :email
    column :fullname
    column :username
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    default_actions
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
    end
    f.actions
  end

end
