ActiveAdmin.register Level do
  include DisableIntercom

  menu parent: 'Startups'

  permit_params :number, :name, :description
end
