module Founders
  # Evaluates a founder's quiz submission and responds with the result section to be sent back.
  class EvaluateEnglishQuizSubmissionService
    def initialize(founder, question, answer_option)
      @founder = founder
      @question = question
      @answer_option = answer_option
    end

    def evaluate
      # Record the submission first.
      EnglishQuizSubmission.create!(
        founder: @founder,
        english_quiz_question: @question,
        answer_option: @answer_option
      )

      # Return the results section.
      result = { title: title, color: color, mrkdwn_in: ['text'] }

      # Add the default footer ...
      explanation = I18n.t('services.founders.evaluate_english_quis_submission.explanation_footer')

      # and prepend it with the question's explanation, if available.
      explanation = "#{@question.explanation}\n\n#{explanation}" if @question.explanation.present?

      result[:text] = explanation

      result
    end

    private

    def answer_correct?
      @answer_correct ||= (@question.correct_answer == @answer_option)
    end

    def title
      answer_correct? ? 'You are right!' : 'Wrong answer!'
    end

    def color
      answer_correct? ? 'good' : 'danger'
    end
  end
end
