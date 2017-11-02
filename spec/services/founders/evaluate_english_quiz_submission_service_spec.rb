require 'rails_helper'

describe Founders::EvaluateEnglishQuizSubmissionService do
  subject { described_class.new(founder, question, answer_option) }

  let(:founder) { create :founder }
  let(:question) { create :english_quiz_question }
  let(:answer_option) { question.correct_answer }

  describe '.evaluate' do
    it 'records the submission and returns the evaluation result' do
      explanation_footer = I18n.t('services.founders.evaluate_english_quis_submission.explanation_footer')
      explanation = "#{question.explanation}\n\n#{explanation_footer}"
      result = {
        title: 'You are right!',
        color: 'good',
        mrkdwn_in: ['text'],
        text: explanation
      }

      expect(subject.evaluate).to eq(result)
      expect(EnglishQuizSubmission.last).to have_attributes(
        quizee: founder,
        english_quiz_question: question,
        answer_option: answer_option
      )
    end
  end
end
