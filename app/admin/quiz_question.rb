ActiveAdmin.register QuizQuestion do
  include DisableIntercom

  permit_params :question, :description, :correct_answer_id, :quiz_id, answer_options_attributes: %i[id value hint _destroy]

  menu parent: 'Targets'

  index do
    selectable_column
    column :question
    column :quiz
    column :correct_answer
    actions
  end

  form do |f|
    f.semantic_errors

    # TODO: Reduce height of the text field below. 'input_html' seems to be malfunctioning
    f.inputs 'Question Details' do
      f.input :question
      f.input :description
      f.input :quiz
      f.input :correct_answer, as: :select, collection: AnswerOption.where(quiz_question: f.object).map { |u| [u.value.to_s, u.id] }
    end

    f.inputs 'Answer Options' do
      f.has_many :answer_options, heading: false, allow_destroy: true, new_record: 'Add Option' do |o|
        o.input :value
        o.input :hint
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :question
      row :quiz
      row :correct_answer
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
