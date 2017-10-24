ActiveAdmin.register EnglishQuizSubmission do
  menu parent: 'English Quiz', label: 'Submissions'
  actions :index

  filter :english_quiz_question_created_at, as: :date_range, label: 'Question Date'
  filter :founder, as: :select, collection: -> { Founder.joins(:english_quiz_submissions) }

  controller do
    def scoped_collection
      super.includes :founder, :english_quiz_question, :answer_option
    end
  end

  index do
    column 'Question Date' do |submission|
      date = submission.english_quiz_question.created_at.strftime('%b %d, %Y')
      link_to date, admin_english_quiz_question_path(submission.english_quiz_question)
    end

    column :founder
    column 'Answer Submitted' do |submission|
      submission.answer_option.value
    end
  end
end
