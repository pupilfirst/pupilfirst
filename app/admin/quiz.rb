ActiveAdmin.register Quiz do
  include DisableIntercom

  menu parent: 'Targets'

  permit_params :title, :target_id, quiz_questions_attributes: %i[question]

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :title
      f.input :target, as: :select, collection: Target.auto_verifiable.map { |u| [u.title.to_s, u.id] }
    end
    f.actions
  end

  index do
    selectable_column
    column :title
    column :target
    actions
  end

  show do
    attributes_table do
      row :title
      row :target
      row :quiz_questions do |o|
        ul do
          o.quiz_questions.pluck(:question).each do |question|
            li question
          end
        end
      end
    end
  end
end
