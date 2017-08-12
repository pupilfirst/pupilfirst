ActiveAdmin.register University do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :name, :state_id

  filter :state
  filter :colleges_name, as: :string
  filter :name, as: :string
  filter :created_at

  index do
    selectable_column

    column :name

    column :colleges do |university|
      link_to university.colleges.count, admin_colleges_path(q: { university_id_eq: university.id })
    end

    column :state

    actions
  end
end
