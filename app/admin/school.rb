ActiveAdmin.register School do
  include DisableIntercom

  menu parent: 'Targets'

  filter :name

  permit_params :name
end
