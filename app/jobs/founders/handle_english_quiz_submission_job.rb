module Founders
  # Evaluates English quiz submissions and responds.
  class HandleEnglishQuizSubmissionJob < ApplicationJob
    queue_as :default

    def perform(payload)
      # Replace the buttons section with the results section ...
      message = payload['original_message']
      message['attachments'][1] = results_section

      # and send it back via the response_url provided.
      RestClient.post(payload['response_url'], message.to_json, content_type: :json)
    end

    private

    # Result section as attachment.
    # TODO: Implement code to evaluate submission and form the response.
    def results_section
      # WIP: Not implemented!
      {
        title: 'Wrong Answer!',
        text: 'The correct answer is x because ...',
        color: 'danger'
      }
    end
  end
end
