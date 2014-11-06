ActiveAdmin.register Company do
  controller do
    newrelic_ignore
  end

  permit_params :name
end
