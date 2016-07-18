ActiveAdmin.register CourseChapter do
  menu parent: 'StartInCollege'
  filter :name
  filter :chapter_number

  permit_params do
    permitted = :name, :chapter_number, :sections_count
    permitted.append(quiz_questions_attributes: [:id, :question, :_destroy, answer_options_attributes: [:id, :value, :correct_answer, :_destroy]])
    permitted
  end

  # permit_params :name, :chapter_number, :sections_count, quiz_questions_attributes: [:id, :question, answer_options_attributes: [:id, :value, :correct_answer, :_destroy], :_destroy]

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :chapter_number
      f.input :sections_count
      f.inputs 'Quiz Questions' do
        f.has_many :quiz_questions, heading: false, allow_destroy: true, new_record: 'Add Question' do |question|
          question.input :question
          question.has_many :answer_options, heading: false, allow_destroy: true, new_record: 'Add Option' do |answer|
            answer.input :value
            answer.input :correct_answer
          end
        end
      end
    end

    f.actions
  end

  index do
    selectable_column

    column :chapter_number
    column :name
    column :sections_count

    actions
  end
end
