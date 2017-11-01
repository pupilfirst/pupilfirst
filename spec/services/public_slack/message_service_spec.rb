require 'rails_helper'

# TODO: Rewrite this spec when rebuilding the MessageService as planned here: https://trello.com/c/onrjenun
describe PublicSlack::MessageService do
  subject { described_class.new }

  before :all do
    PublicSlack::MessageService.mock = false
  end

  after :all do
    PublicSlack::MessageService.mock = true
  end

  describe '.post' do
    let(:founder_1) { create :founder }
    let(:founder_2) { create :founder }

    it 'raises ArgumentError if no target specified' do
      expect { subject.post message: 'Hello' }.to raise_error(ArgumentError, 'specify one of channel, founder or founders')
    end

    it 'raises ArgumentError if multiple targets specified' do
      expect { subject.post message: 'Hello', channel: '#general', founder: founder_1 }.to raise_error(
        ArgumentError, 'specify one of channel, founder or founders'
      )

      expect { subject.post message: 'Hello', founder: founder_1, founders: [founder_1, founder_2] }.to raise_error(
        ArgumentError, 'specify one of channel, founder or founders'
      )

      expect { subject.post message: 'Hello', channel: '#general', founders: [founder_1, founder_2] }.to raise_error(
        ArgumentError, 'specify one of channel, founder or founders'
      )
    end

    context 'when targets are correctly specified' do
      context 'when valid channel is supplied' do
        it 'sends message to channel' do
          expect(subject).to receive(:channel_valid?).and_return(true)
          expect(subject).to receive(:post_to_channel)
          subject.post message: 'Hello', channel: '#general'
        end

        context 'when supplied channel is invalid' do
          it 'fails' do
            expect(subject).to receive(:channel_valid?).and_return(false)

            expect { subject.post message: 'Hello', channel: '#general' }.to raise_error(
              'could not validate channel specified'
            )
          end
        end
      end

      context 'when single founder is supplied' do
        it 'send message to founder' do
          expect(subject).to receive(:post_to_founder).once
          subject.post message: 'Hello', founder: founder_1
        end
      end

      context 'when multiple founders are supplied' do
        it 'send messages to all founders' do
          expect(subject).to receive(:post_to_founders).once
          subject.post message: 'Hello', founders: [founder_1, founder_2]
        end
      end

      context 'when slack responds with an error' do
        it 'records the error' do
          expect(subject).to receive(:channel_valid?).and_return(true)
          stub_request(:get, "https://slack.com/api/chat.postMessage?token=BOT_OAUTH_TOKEN&channel=channel_name"\
            "&link_names=1&text=hello&as_user=true&unfurl_links=false")
            .to_return(body: '{"error": "some error"}')

          expect { subject.post message: 'hello', channel: 'channel_name' }.to raise_error(PublicSlack::OperationFailureException, %q(Response from Slack API indicates failure: '{"error": "some error"}'))
        end
      end

      context 'when an HTTP error occurs' do
        it 'records the error' do
          expect(subject).to receive(:channel_valid?).and_return(true)
          stub_request(:get, "https://slack.com/api/chat.postMessage?token=BOT_OAUTH_TOKEN&channel=channel_name"\
            "&link_names=1&text=hello&as_user=true&unfurl_links=false")
            .to_return(body: 'some error', status: 500)

          response = subject.post message: 'hello', channel: 'channel_name'
          expect(response.errors).to eq('HTTP Error' => 'There seems to be a network issue. Please try after sometime')
        end
      end
    end
  end
end
