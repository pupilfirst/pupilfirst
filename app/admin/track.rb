ActiveAdmin.register Track do
  include DisableIntercom

  menu parent: 'Targets'

  filter :name

  permit_params :name, :sort_index
end
