ActiveAdmin.register Skill do
  include DisableIntercom

  menu parent: 'Targets'

  permit_params :name, :description

  filter :name
  filter :description

  index do
    selectable_column

    column :id
    column :name
    column :description

    actions
  end

  form do |f|
    div id: 'admin-skill__edit'
    f.inputs 'Skill Details' do
      f.input :name
      f.input :description
    end

    f.actions
  end
end
