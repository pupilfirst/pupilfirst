require 'rails_helper'

describe PublicSlack::PostEnglishQuestionService do
  subject { described_class.new }

  let!(:quiz_question) { create :english_quiz_question }

  # Two Slack connected founders ...
  let!(:founder_1) { create :founder, slack_user_id: 'slack_1' }
  let!(:founder_2) { create :founder, slack_user_id: 'slack_2' }
  # ... and one who is not .
  let!(:founder_3) { create :founder }

  describe '.post' do
    context 'when there is an English Question without any submissions' do
      it 'DMs the question to all founders with a slack_user_id' do
        attachments = subject.send(:question_as_slack_attachment)
        expect(PublicSlack::PostEnglishQuestionJob).to receive(:perform_later).with(channels: %w[slack_1 slack_2], attachments: attachments)
        subject.post
      end
    end

    context 'when there is no new English Question without submissions' do
      before do
        # Create a submission for the existing question.
        EnglishQuizSubmission.create!(
          english_quiz_question: quiz_question,
          founder: founder_1,
          answer_option: quiz_question.answer_options.sample
        )
      end

      it 'does nothing' do
        expect(PublicSlack::PostEnglishQuestionJob).to_not receive(:perform_later)
        subject.post
      end
    end
  end
end
