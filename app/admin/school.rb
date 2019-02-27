ActiveAdmin.register School do
  actions :all, except: %i[new edit update create destroy]

  controller do
    include DisableIntercom
  end

  filter :name

  show do
    attributes_table do
      row :name
      row :subdomain
      row :domain

      row :founder_tags do |school|
        linked_tags(school.founder_tags)
      end
    end
  end
end
