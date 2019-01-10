ActiveAdmin.register EvaluationCriterion do
  controller do
    include DisableIntercom
  end

  menu parent: 'Targets'

  permit_params :name, :description, :course_id

  filter :name
  filter :description

  index do
    selectable_column

    column :id
    column :name
    column :description
    column :course

    actions
  end

  form do |f|
    div id: 'admin-skill__edit'
    f.inputs 'EvaluationCriterion Details' do
      f.input :name
      f.input :description
      f.input :course
    end

    f.actions
  end
end
