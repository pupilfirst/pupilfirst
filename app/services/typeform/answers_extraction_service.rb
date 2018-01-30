module Typeform
  # The service extracts answers by a user from Typeform webhook response to a readable format before storing them.
  class AnswersExtractionService
    def initialize(response)
      @response = response
    end

    def execute
      # Collection of all questions in the form
      form_questions_data = @response['definition']['fields'] || []

      # Extract questions in the format: { question_id => question_title }
      question_hash = form_questions_data.each_with_object({}) do |question_data, hash|
        hash[question_data['id']] = question_data['title']
      end

      # Collection of all form responses from a user
      answers = @response['answers']

      # Extract answers and generate form response into the required format: [{ question: q1, answer: a1},]
      consolidated_response_data = {
        response: answers.map do |answer|
          question = question_hash[answer['field']['id']]
          { question: question, answer: answer[answer['type']] }
        end
      }

      # Add score to response data if present.
      consolidated_response_data['score'] = @response['calculated']['score'] if @response['calculated'].present?

      consolidated_response_data
    end
  end
end
