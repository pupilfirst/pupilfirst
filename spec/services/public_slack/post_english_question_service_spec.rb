require 'rails_helper'

describe PublicSlack::PostEnglishQuestionService do
  subject { described_class.new }

  let!(:quiz_question) { create :english_quiz_question }

  # Two Slack connected founders ...
  let!(:founder_1) { create :founder, slack_user_id: 'slack_1' }
  let!(:founder_2) { create :founder, slack_user_id: 'slack_2' }
  # ... and one who is not .
  let!(:founder_3) { create :founder }
  # A Slack connected team faculty too.
  let!(:faculty) { create :faculty, category: 'team', slack_user_id: 'slack_3' }

  describe '.post' do
    context 'when there is an English Question without any submissions' do
      it 'DMs the question to all founders with a slack_user_id' do
        attachments = subject.send(:question_as_slack_attachment)
        expect(Founders::PostEnglishQuestionJob).to receive(:perform_later).with(channel: 'slack_1', attachments: attachments)
        expect(Founders::PostEnglishQuestionJob).to receive(:perform_later).with(channel: 'slack_2', attachments: attachments)
        expect(Founders::PostEnglishQuestionJob).to receive(:perform_later).with(channel: 'slack_3', attachments: attachments)
        expect(Founders::PostEnglishQuestionJob).to receive(:perform_later).with(channel: 'U0A6X5MEY', attachments: attachments) # because @manojmohan is hardwired as special-case
        subject.post

        # The posted_on must be now set.
        expect(quiz_question.reload.posted_on).to eq(Date.today)
      end
    end

    context 'when there is no new un-posted English' do
      before do
        # Mark the question as posted.
        quiz_question.update!(posted_on: Date.today)
      end

      it 'does nothing' do
        expect(Founders::PostEnglishQuestionJob).to_not receive(:perform_later)
        subject.post
      end
    end
  end
end
