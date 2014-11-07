ActiveAdmin.register Connection do
  controller do
    newrelic_ignore
  end

  index do
    column :user do |connection|
      sv_id_link(connection.user) if connection.user.present?
    end

    column :contact do |connection|
      sv_id_link(connection.contact) if connection.contact.present?
    end

    column :created_at
    column :direction
  end

  form partial: 'admin/connections/form'

  permit_params :user_id, :contact_id, :direction
end
