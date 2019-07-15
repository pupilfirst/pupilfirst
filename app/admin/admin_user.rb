ActiveAdmin.register AdminUser do
  actions :all, except: %i[new edit update create destroy]

  controller do
    include DisableIntercom
  end

  menu parent: 'Dashboard'

  filter :email, as: :string
  filter :fullname
  filter :admin_type, as: :select, collection: -> { AdminUser.admin_user_types }

  index do
    id_column

    column :email
    column :fullname
    column :admin_type

    actions
  end
end
