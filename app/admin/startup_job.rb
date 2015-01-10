ActiveAdmin.register StartupJob do
  controller do
    newrelic_ignore
  end
  permit_params :title, :description, :salary_max, :salary_min, :equity_max, :equity_min, :equity_vest, :equity_cliff, :expires_on
end