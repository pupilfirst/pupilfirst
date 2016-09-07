ActiveAdmin.register College do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :name, :also_known_as, :city, :state_id, :established_year, :website, :contact_numbers,
    :replacement_university_id

  filter :state
  filter :state_id_null, label: 'State missing?', as: :boolean
  filter :city
  filter :city_null, label: 'City missing?', as: :boolean
  filter :replacement_university
  filter :replacement_university_id_null, label: 'University missing?', as: :boolean
  filter :name

  index do
    selectable_column

    column :name
    column :city
    column :state
    column :replacement_university
    column :also_known_as

    actions
  end
end
