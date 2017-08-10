ActiveAdmin.register Level do
  include DisableIntercom

  menu parent: 'Startups'

  permit_params :number, :name, :description

  filter :name, as: :string
  filter :description, as: :string
  filter :number
  filter :created_at
end
