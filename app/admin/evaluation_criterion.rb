ActiveAdmin.register EvaluationCriterion do
  controller do
    include DisableIntercom
  end

  menu parent: 'Targets'

  permit_params :name, :description, :school_id

  filter :name
  filter :description

  index do
    selectable_column

    column :id
    column :name
    column :description
    column :school

    actions
  end

  form do |f|
    div id: 'admin-skill__edit'
    f.inputs 'EvaluationCriterion Details' do
      f.input :name
      f.input :description
      f.input :school
    end

    f.actions
  end
end
