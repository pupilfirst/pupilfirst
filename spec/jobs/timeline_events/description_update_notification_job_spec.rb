require 'rails_helper'

describe TimelineEvents::DescriptionUpdateNotificationJob do
  subject { described_class }

  let(:mock_public_slack_talk) { instance_double(PublicSlackTalk) }
  let(:new_line) { Faker::Lorem.sentence }
  let(:unchanged_line) { Faker::Lorem.sentence }
  let(:old_line) { Faker::Lorem.sentence }
  let(:timeline_event) { create :timeline_event, description: "#{new_line}\n#{unchanged_line}\n" }
  let(:old_description) { "#{unchanged_line}\n#{old_line}\n" }

  let(:expected_heading) do
    I18n.t(
      'jobs.timeline_event.description_update_notification.heading',
      event_title: timeline_event.title,
      event_url: timeline_event.share_url
    )
  end

  let(:expected_filename) { "Updated #{timeline_event.title}".parameterize + '.txt' }

  let(:expected_diff) do
    <<~EXPECTED_DIFF.strip
      +#{new_line}
       #{unchanged_line}
      -#{old_line}
    EXPECTED_DIFF
  end

  describe '#perform' do
    it 'sends diff to author of timeline event' do
      expect(PublicSlackTalk).to receive(:post_message).with(message: expected_heading, founder: timeline_event.founder)
      expect(PublicSlackTalk).to receive(:new).with(message: 'ignored', founder: timeline_event.founder).and_return(mock_public_slack_talk)
      expect(mock_public_slack_talk).to receive(:upload_file).with(expected_diff, 'diff', expected_filename)

      subject.perform_now(timeline_event, old_description)
    end
  end
end
