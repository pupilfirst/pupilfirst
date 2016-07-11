ActiveAdmin.register University do
  menu parent: 'Admissions'
  filter :name

  permit_params :name, :location
end
