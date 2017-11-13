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

  let(:mock_api_service) { instance_double(PublicSlack::ApiService) }

  describe '.post' do
    context 'when there is an English Question without any submissions' do
      it 'DMs the question to all founders with a slack_user_id' do
        expect(PublicSlack::ApiService).to receive(:new).and_return(mock_api_service)

        expect(mock_api_service).to receive(:get)
          .with('chat.postMessage', params: params('slack_1'))
          .and_return('ok' => true)
        expect(mock_api_service).to receive(:get)
          .with('chat.postMessage', params: params('slack_2'))
          .and_return('ok' => true)
        expect(mock_api_service).to receive(:get)
          .with('chat.postMessage', params: params('slack_3'))
          .and_return('ok' => true)
        expect(mock_api_service).to receive(:get)
          .with('chat.postMessage', params: params('U0A6X5MEY'))
          .and_return('ok' => true) # because @manojmohan is hardwired as special-case
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
        expect(PublicSlack::ApiService).to_not receive(:new)
        subject.post
      end
    end
  end

  private

  def params(slack_user_id)
    { channel: slack_user_id, as_user: true, attachments: subject.send(:question_as_slack_attachment) }
  end
end
