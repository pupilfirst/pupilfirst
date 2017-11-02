ActiveAdmin.register EnglishQuizSubmission do
  menu parent: 'English Quiz', label: 'Submissions'
  actions :index

  filter :english_quiz_question_created_at, as: :date_range, label: 'Question Date'

  controller do
    def scoped_collection
      super.includes :quizee, :english_quiz_question, :answer_option
    end
  end

  index do
    column 'Question Date' do |submission|
      date = submission.english_quiz_question.created_at.strftime('%b %d, %Y')
      link_to date, admin_english_quiz_question_path(submission.english_quiz_question)
    end

    column :quizee

    column 'Correct Answer' do |submission|
      submission.answer_option == submission.english_quiz_question.correct_answer
    end

    column 'Answer Submitted' do |submission|
      submission.answer_option.value
    end
  end
end
