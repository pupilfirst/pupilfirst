ActiveAdmin.register Track do
  controller do
    include DisableIntercom
  end

  menu parent: 'Targets'

  filter :name

  permit_params :name, :sort_index
end
