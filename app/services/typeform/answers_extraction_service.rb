module Typeform
  # The service extracts answers by a user from Typeform webhook response to a readable format before storing them.
  class AnswersExtractionService
    def initialize(response)
      @response = response
    end

    def execute
      # Collection of all questions in the form
      form_questions_data = @response['definition']['fields']

      # Extract questions in the format: { question_id => question_title }
      question_hash = form_questions_data.each_with_object({}) do |question_data, hash|
        hash[question_data['id']] = question_data['title']
      end

      # Collection of all form responses from a user
      form_response_data = @response['answers']

      consolidated_response_data = {}

      # Extract answers and generate form response into the required format: { question => answers }
      consolidated_response_data['response'] = form_response_data.each_with_object({}) do |response_data, question_and_answers|
        question = question_hash[response_data['field']['id']]
        question_and_answers[question] = response_data[response_data['type']]
      end

      # Add score to response data if present
      consolidated_response_data['score'] = @response['calculated']['score'] if @response['calculated'].present?

      consolidated_response_data
    end
  end
end
