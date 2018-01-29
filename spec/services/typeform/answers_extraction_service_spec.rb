require 'rails_helper'

describe Typeform::AnswersExtractionService do
  describe '#execute' do
    subject { described_class.new(typeform_response) }

    let(:typeform_response) do
      {
        'form_id' => 'pWmL9d',
        'token' => '4969bac7b56e83a82ad060f0ae57faed',
        'submitted_at' => '2017-07-13T10:00:32Z',
        'calculated' => {
          'score' => 42
        },
        'definition' => {
          'id' => 'pWmL9d',
          'title' => 'all_questions_test',
          'fields' => [
            {
              'id' => '36754465',
              'title' => '1. Short text',
              'type' => 'short_text'
            }
          ]
        },
        'answers' => [
          {
            'type' => 'text',
            'text' => 'Lorem ipsum dolor',
            'field' => {
              'id' => '36754465',
              'type' => 'short_text'
            }
          }
        ]
      }
    end

    it 'returns survey answers in the required format' do
      extracted_answers = {
        :response =>
        [{ question: "1. Short text", answer: "Lorem ipsum dolor" }],
        'score' => 42
      }
      expect(subject.execute).to eq(extracted_answers)
    end
  end
end
