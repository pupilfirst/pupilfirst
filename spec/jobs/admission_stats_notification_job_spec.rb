require 'rails_helper'

describe AdmissionStatsNotificationJob do
  subject { described_class }

  it 'posts the expected message to Slack' do
    pending

    expect(RestClient).to receive(:post).with('payload', 'url')

    subject.perform_now
  end
end
