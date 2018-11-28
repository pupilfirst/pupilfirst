ActiveAdmin.register QuizQuestion do
  include DisableIntercom

  permit_params :question, :description, :quiz_id, answer_options_attributes: %i[id value correct_answer hint _destroy]

  menu parent: 'Targets'

  index do
    selectable_column
    column :question
    column :quiz
    column :correct_answer do |question|
      question.correct_answer.value if question.correct_answer.present?
    end
    actions
  end

  form do |f|
    f.semantic_errors

    # TODO: Reduce height of the text field below. 'input_html' seems to be malfunctioning
    f.inputs 'Question Details' do
      f.input :question
      f.input :description
      f.input :quiz
    end

    f.inputs 'Answer Options' do
      f.has_many :answer_options, heading: false, allow_destroy: true, new_record: 'Add Option' do |o|
        o.input :value
        o.input :correct_answer
        o.input :hint
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :question
      row :quiz
      row :correct_answer do |question|
        question.correct_answer.value if question.correct_answer.present?
      end
      row :answer_options do |question|
        ul do
          question.answer_options.pluck(:value).each do |answer|
            li answer
          end
        end
      end
    end
  end
end
