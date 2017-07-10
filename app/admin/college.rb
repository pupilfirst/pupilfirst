ActiveAdmin.register College do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :name, :also_known_as, :city, :state_id, :established_year, :website, :contact_numbers, :university_id

  filter :state
  filter :state_id_null, label: 'State missing?', as: :boolean
  filter :city
  filter :city_null, label: 'City missing?', as: :boolean
  filter :university
  filter :university_id_null, label: 'University missing?', as: :boolean
  filter :name
  filter :also_known_as

  index do
    selectable_column

    column :name
    column :city
    column :state
    column :university
    column :also_known_as

    actions
  end
end
