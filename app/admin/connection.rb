ActiveAdmin.register Connection do
  controller do
    newrelic_ignore
  end

  index do
    column :user do |connection|
      name_link connection.user
    end

    column :contact do |connection|
      name_link connection.contact
    end

    column :created_at
    column :direction
  end

  form partial: 'admin/connections/form'

  permit_params :user_id, :contact_id, :direction
end
