require 'rails_helper'

describe EnglishQuizQuestions::EvaluateSubmissionService do
  subject { described_class.new(payload) }

  let!(:founder) { create :founder, slack_user_id: 'slack_user_1' }
  let!(:question) { create :english_quiz_question }
  let!(:answer_option) { question.correct_answer }
  let(:payload) do
    {
      'callback_id' => "english_quiz_#{question.id}",
      'actions' => ['value' => answer_option.id],
      'user' => { 'id' => 'slack_user_1' },
      'original_message' => { 'attachments' => %w[first_attachment second_attachment] }
    }
  end

  describe '.evaluate' do
    context 'when the founder is responding to the question for the first time' do
      it 'records the submission and returns the evaluation result' do
        explanation_footer = I18n.t('services.founders.evaluate_english_quis_submission.explanation_footer')
        explanation = "#{question.explanation}\n\n#{explanation_footer}"
        result = {
          title: 'You are right!',
          color: 'good',
          mrkdwn_in: ['text'],
          text: explanation
        }

        expected_response = payload['original_message']
        expected_response['attachments'][1] = result

        expect(subject.evaluate).to eq(expected_response)
        expect(EnglishQuizSubmission.last).to have_attributes(
          quizee: founder,
          english_quiz_question: question,
          answer_option: answer_option
        )
      end
    end

    context 'when the founder has already answered this question' do
      before do
        EnglishQuizSubmission.create!(
          quizee: founder,
          english_quiz_question: question,
          answer_option: answer_option
        )
      end

      it 'does nothing and returns nil' do
        expect(subject.evaluate).to be_nil
      end
    end
  end
end
