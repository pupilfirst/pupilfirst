module Founders
  # Evaluates English quiz submissions and responds.
  class HandleEnglishQuizSubmissionJob < ApplicationJob
    queue_as :default

    def perform(payload)
      founder = Founder.find_by!(slack_user_id: payload['user']['id'])

      # Parse the quiz question id from the callback_id.
      question_id = payload['callback_id'][/english_quiz_(\d+)/, 1]
      question = EnglishQuizQuestion.find_by!(id: question_id)

      answer_option = AnswerOption.find_by!(id: payload['actions'][0]['value'])

      # Call the service to evaluate the submission.
      results_section = Founders::EvaluateEnglishQuizSubmission.new(founder, question, answer_option).evaluate

      # Replace the buttons section with the results section ...
      message = payload['original_message']
      message['attachments'][1] = results_section

      # and send it back via the response_url provided.
      RestClient.post(payload['response_url'], message.to_json, content_type: :json)
    end
  end
end
