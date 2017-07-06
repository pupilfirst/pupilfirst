ActiveAdmin.register University do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :name, :state_id

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
