ActiveAdmin.register University do
  include DisableIntercom

  menu parent: 'Admissions'
  filter :name

  permit_params :name, :location
end
