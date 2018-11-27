ActiveAdmin.register Quiz do
  include DisableIntercom

  menu parent: 'Targets'

  permit_params :title, :target_id, quiz_questions_attributes: %i[question description _destroy], answer_options_attributes: %i[id value correct_answer hint _destroy]

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :target, as: :select
    end
    f.actions
  end

  index do
    selectable_column
    column :title

    actions
  end

  show do
    attributes_table do
      row :title
      row :target
    end
  end
end
