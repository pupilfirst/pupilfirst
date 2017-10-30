require 'rails_helper'

describe Founders::EvaluateEnglishQuizSubmissionService do
  subject { described_class.new(founder, question, answer_option) }

  let(:founder) { create :founder }
  let(:question) { create :english_quiz_question }
  let(:answer_option) { question.correct_answer }

  describe '.evaluate' do
    it 'records the submission and returns the evaluation result' do
      result = {
        title: 'You are right!',
        color: 'good',
        text: question.explanation
      }

      expect(subject.evaluate).to eq(result)
      expect(EnglishQuizSubmission.last).to have_attributes(
        founder: founder,
        english_quiz_question: question,
        answer_option: answer_option
      )
    end
  end
end
