module Schools
  class QuizzesController < SchoolsController
    before_action :quiz, except: :create

    # POST /school/targets/:target_id/quizzes
    def create
      authorize(Quiz, policy_class: Schools::QuizPolicy)
      form = ::Schools::Quizzes::CreateForm.new(Quiz.new)
      if form.validate(params[:quiz])
        form.save
        redirect_back(fallback_location: school_path)
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    def update
      form = ::Schools::Quizzes::UpdateForm.new(@quiz)

      if form.validate(params[:quiz])
        form.save
        redirect_to edit_school_target_path(@quiz.target)
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    private

    def quiz
      @quiz = authorize(Quiz.find(params[:quiz][:id].to_i), policy_class: Schools::QuizPolicy)
    end
  end
end
