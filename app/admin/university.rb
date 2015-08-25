ActiveAdmin.register University do
  filter :name

  permit_params :name, :location
end
