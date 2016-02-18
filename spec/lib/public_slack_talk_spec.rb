require 'rails_helper'

describe 'Public Slack Talk' do
  subject { PublicSlackTalk }

  describe '.post_message' do
    let(:founder_1) { create :founder_with_out_password }
    let(:founder_2) { create :founder_with_out_password }

    it 'raises ArgumentError if no target specified' do
      expect { subject.post_message message: 'Hello' }.to raise_error(ArgumentError, 'specify one of channel, founder or founders')
    end

    it 'raises ArgumentError if multiple targets specified' do
      expect { PublicSlackTalk.post_message message: 'Hello', channel: '#general', founder: founder_1 }.to raise_error(
        ArgumentError, 'specify one of channel, founder or founders')
      expect { PublicSlackTalk.post_message message: 'Hello', founder: founder_1, founders: [founder_1, founder_2] }.to raise_error(
        ArgumentError, 'specify one of channel, founder or founders')
      expect { PublicSlackTalk.post_message message: 'Hello', channel: '#general', founders: [founder_1, founder_2] }.to raise_error(
        ArgumentError, 'specify one of channel, founder or founders')
    end

    context 'when targets are correctly specified' do
      context 'when valid channel is supplied' do
        it 'sends message to channel' do
          expect_any_instance_of(PublicSlackTalk).to receive(:channel_valid?).and_return(true)
          expect_any_instance_of(PublicSlackTalk).to receive(:post_to_channel)
          PublicSlackTalk.post_message message: 'Hello', channel: '#general'
        end

        context 'when supplied channel is invalid' do
          it 'fails' do
            expect_any_instance_of(PublicSlackTalk).to receive(:channel_valid?).and_return(false)
            expect { PublicSlackTalk.post_message message: 'Hello', channel: '#general' }.to raise_error(
              'could not validate channel specified')
          end
        end
      end

      context 'when single founder is supplied' do
        it 'send message to founder' do
          expect_any_instance_of(PublicSlackTalk).to receive(:post_to_founder).once
          PublicSlackTalk.post_message message: 'Hello', founder: founder_1
        end
      end

      context 'when multiple founders are supplied' do
        it 'send messages to all founders' do
          expect_any_instance_of(PublicSlackTalk).to receive(:post_to_founders).once
          PublicSlackTalk.post_message message: 'Hello', founders: [founder_1, founder_2]
        end
      end

      context 'when slack responds with an error' do
        it 'records the error' do
          pending 'by responding with a certain error response'
          expect(1).to eq(2)
        end
      end

      context 'when an HTTP error occurs' do
        it 'records the error' do
          pending 'by responding with a certain error response'
          expect(1).to eq(2)
        end
      end
    end
  end

  context '.post_message' do
    let(:founder) { create :founder_with_out_password }

    it 'raises ArgumentError if no target specified' do
      expect { PublicSlackTalk.post_message message: 'Hello' }.to raise_error(
        ArgumentError, 'specify one of channel, founder or founders')
    end

    it 'raises ArgumentError if multiple targets specified' do
      expect { PublicSlackTalk.post_message message: 'Hello', channel: '#general', founder: founder }.to raise_error(
        ArgumentError, 'specify one of channel, founder or founders')
    end

    it 'calls process on a new PublicSlackTalk instance if exactly one target specified' do
      expect_any_instance_of(PublicSlackTalk).to receive(:process)
      PublicSlackTalk.post_message message: 'Hello', channel: '#general'
    end
  end

  context '#process' do
    let(:founder1) { create :founder_with_out_password }
    let(:founder2) { create :founder_with_out_password }
    it 'raises exception if target is an invalid channel' do
      instance = PublicSlackTalk.new channel: '#abcd', message: 'hello'
      expect(instance).to receive(:channel_valid?).and_return(false)
      expect { instance.process }.to raise_error('could not validate channel specified')
    end

    it 'calls #post_to_channel if target is valid channel' do
      instance = PublicSlackTalk.new channel: '#abcd', message: 'hello'
      expect(instance).to receive(:channel_valid?).and_return(true)
      expect(instance).to receive(:post_to_channel)
      instance.process
    end

    it 'calls #post_to_founder exactly once if target is a founder' do
      instance = PublicSlackTalk.new founder: founder1, message: 'hello'
      expect(instance).to receive(:post_to_founder).once
      instance.process
    end

    it 'calls #post_to_founders exactly once if target is array of founders' do
      instance = PublicSlackTalk.new founders: [founder1, founder2], message: 'hello'
      expect(instance).to receive(:post_to_founders).once
      instance.process
    end
  end

  context '#post_to_founder' do
    let(:founder) { create :founder_with_out_password }
    it 'invokes post_to_channel if im_id fetched' do
      instance = PublicSlackTalk.new founder: founder, message: 'hello'
      expect(instance).to receive(:fetch_im_id).and_return(true)
      expect(instance).to receive(:post_to_channel)
      instance.post_to_founder
    end

    it 'does not invoke post_to_channel if im_id not fetched' do
      instance = PublicSlackTalk.new founder: founder, message: 'hello'
      expect(instance).to receive(:fetch_im_id).and_return(false)
      expect(instance).to_not receive(:post_to_channel)
      instance.post_to_founder
    end
  end

  context '#post_to_founders' do
    let(:founder1) { create :founder_with_out_password }
    let(:founder2) { create :founder_with_out_password }
    it 'calls #post_to_founder n times if target is array of n founders' do
      instance = PublicSlackTalk.new founders: [founder1, founder2], message: 'hello'
      expect(instance).to receive(:post_to_founder).twice
      instance.post_to_founders
    end
  end

  # context '#post_to_channel' do
  #   instance = PublicSlackTalk.new channel: 'general', message: 'hello'
  #   instance.instance_variable_set(:@token, 'xxxxxx')
  #
  #   it 'does not add errors if response is ok' do
  #     success_response = stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=general'\
  #     '&text=hello&token=xxxxxx&unfurl_links=false')
  #       .to_return(body: '{"ok":true}')
  #     instance.post_to_channel
  #     expect(success_response).to have_been_made.once
  #     expect(instance.errors).to be_empty
  #     remove_request_stub(success_response)
  #   end
  #
  #   it 'adds errors if response is not ok' do
  #     fail_response = stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=general'\
  #     '&text=hello&token=xxxxxx&unfurl_links=false')
  #       .to_return(body: '{"ok":false, "error": "some error"}')
  #     instance.post_to_channel
  #     expect(fail_response).to have_been_made.once
  #     expect(instance.errors['Slack']).to eq('some error')
  #     remove_request_stub(fail_response)
  #   end
  # end
  #
  # context '#channel_valid?' do
  #   instance = PublicSlackTalk.new channel: 'general', message: 'hello'
  #   instance.instance_variable_set(:@token, 'xxxxxx')
  #
  #   it 'returns false if channel list could not be fetched' do
  #     success_response = stub_request(:get, 'https://slack.com/api/channels.list?token=xxxxxx')
  #       .to_return(body: '{"ok":false}')
  #     instance.channel_valid?
  #     expect(success_response).to have_been_made.once
  #     expect(instance.channel_valid?).to be false
  #     remove_request_stub(success_response)
  #   end
  # end
end
