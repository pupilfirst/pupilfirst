module EnglishQuizQuestions
  # Evaluates submissions for the English quiz and responds with the result.
  class EvaluateSubmissionService
    def initialize(payload)
      @payload = payload
    end

    def evaluate
      # Do nothing if the quizee has already answered this question.
      return nil if quizee.english_quiz_submissions.where(english_quiz_question: question).present?

      # Record the submission first.
      EnglishQuizSubmission.create!(
        quizee: quizee, english_quiz_question: question, answer_option: answer_option
      )

      # Replace the buttons section with the evaluation result.
      message = @payload['original_message']
      message['attachments'][1] = evaluation_result

      message
    end

    private

    def question
      @question ||= begin
        question_id = @payload['callback_id'][/english_quiz_(\d+)/, 1]
        EnglishQuizQuestion.find_by!(id: question_id)
      end
    end

    def answer_option
      @answer_option ||= AnswerOption.find_by!(id: @payload['actions'][0]['value'])
    end

    def quizee
      @quizee ||= begin
        founder = Founder.find_by(slack_user_id: @payload['user']['id'])
        founder.present? ? founder : Faculty.find_by(slack_user_id: @payload['user']['id'])
      end
    end

    def evaluation_result
      { title: title, color: color, mrkdwn_in: ['text'], text: explanation }
    end

    def explanation
      # Add the default footer to the result ...
      explanation = I18n.t('services.english_quiz_questions.evaluate_submission.explanation_footer')
      # and prepend it with the question's explanation, if available.
      explanation = "#{question.explanation}\n\n#{explanation}" if question.explanation.present?

      explanation
    end

    def answer_correct?
      @answer_correct ||= (question.correct_answer == answer_option)
    end

    def title
      answer_correct? ? 'You are right!' : 'Wrong answer!'
    end

    def color
      answer_correct? ? 'good' : 'danger'
    end
  end
end
