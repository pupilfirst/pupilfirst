ActiveAdmin.register Company do
  menu parent: 'Mentoring'

  controller do
    newrelic_ignore
  end

  permit_params :name
end
