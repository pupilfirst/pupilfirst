ActiveAdmin.register EnglishQuizQuestion do
  menu parent: 'English Quiz', label: 'Questions'
  permit_params :question, :explanation, answer_options_attributes: %i[id value correct_answer _destroy]

  filter :explanation
  filter :posted_on

  controller do
    include DisableIntercom

    def scoped_collection
      super.includes :correct_answer
    end
  end

  show do |english_quiz_question|
    attributes_table do
      row :question do
        link_to english_quiz_question.question.url do
          image_tag english_quiz_question.question.url, width: '400px'
        end
      end

      row :answer_options do
        ul do
          english_quiz_question.answer_options.pluck(:value).each do |answer|
            li answer
          end
        end
      end
      row :correct_answer do
        english_quiz_question.correct_answer&.value
      end

      row :explanation
      row :posted_on
    end
  end

  index do
    selectable_column

    column :question do |english_quiz_question|
      link_to english_quiz_question.question.url do
        image_tag english_quiz_question.question.url, width: '200px'
      end
    end

    column :correct_answer do |english_quiz_question|
      english_quiz_question.correct_answer&.value
    end

    column :explanation
    column :posted_on

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Question Details' do
      f.input :question
      f.input :explanation
    end

    f.inputs 'Answer Options' do
      f.has_many :answer_options, heading: false, allow_destroy: true, new_record: 'Add Option' do |o|
        o.input :value
        o.input :correct_answer
      end
    end
    f.actions
  end
end
