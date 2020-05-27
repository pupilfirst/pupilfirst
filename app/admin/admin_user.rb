ActiveAdmin.register AdminUser do
  actions :all, except: %i[new edit update create destroy]

  menu parent: 'Dashboard'

  filter :email, as: :string
  filter :fullname

  index do
    id_column

    column :email
    column :fullname

    actions
  end
end
