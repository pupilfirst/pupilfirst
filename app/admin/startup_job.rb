ActiveAdmin.register StartupJob do
  controller do
    newrelic_ignore
  end

  index do
    selectable_column
    actions
    column :title
    column :contact_name
    column :contact_email
    column :contact_number
    column :created_at
    column :expires_on
  end

  permit_params :title, :description, :salary_max, :salary_min, :equity_max, :equity_min, :equity_vest, :equity_cliff,
    :expires_on, :startup_id, :skills, :experience, :qualification, :contact_number, :contact_name
end