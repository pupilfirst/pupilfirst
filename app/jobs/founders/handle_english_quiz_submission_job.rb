module Founders
  # Evaluates English quiz submissions and responds.
  class HandleEnglishQuizSubmissionJob < ApplicationJob
    queue_as :high_priority

    def perform(payload)
      # Parse the quiz question id from the callback_id.
      question_id = payload['callback_id'][/english_quiz_(\d+)/, 1]
      question = EnglishQuizQuestion.find_by!(id: question_id)

      # Fetch the associated quizee - Founder or Faculty.
      founder = Founder.find_by(slack_user_id: payload['user']['id'])
      faculty = Faculty.find_by(slack_user_id: payload['user']['id'])
      quizee = founder.present? ? founder : faculty

      # Do nothing if the quizee has already answered this question.
      return if quizee.english_quiz_submissions.where(english_quiz_question: question).present?

      answer_option = AnswerOption.find_by!(id: payload['actions'][0]['value'])

      # Call the service to evaluate the submission.
      results_section = Founders::EvaluateEnglishQuizSubmissionService.new(quizee, question, answer_option).evaluate

      # Replace the buttons section with the results section ...
      message = payload['original_message']
      message['attachments'][1] = results_section

      # and send it back via the response_url provided.
      RestClient.post(payload['response_url'], message.to_json, content_type: :json)
    end
  end
end
