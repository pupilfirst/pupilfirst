ActiveAdmin.register Target do
  menu parent: 'Startups'

  permit_params :startup_id, :role, :status, :title, :short_description, :resource_url

  form partial: 'admin/targets/form'
end
