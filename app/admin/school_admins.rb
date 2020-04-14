ActiveAdmin.register SchoolAdmin do
  menu parent: 'Schools'
  permit_params :user_id, :school_id
  actions :index, :show

  filter :school
  filter :user_email, as: :string

  controller do
    def scoped_collection
      super.includes :user, school: :domains
    end
  end

  index do
    id_column

    column :user
    column :school
    column :fqdn do |admin|
      admin.school.domains.first.fqdn
    end
  end
end
