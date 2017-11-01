require 'rails_helper'

describe TimelineEvents::DescriptionUpdateNotificationJob do
  subject { described_class }

  let(:mock_message_service) { instance_double(PublicSlack::MessageService) }
  let(:mock_send_file_service) { instance_double(PublicSlack::SendFileService) }
  let(:new_line) { Faker::Lorem.sentence }
  let(:unchanged_line) { Faker::Lorem.sentence }
  let(:old_line) { Faker::Lorem.sentence }
  let(:timeline_event) { create :timeline_event, description: "#{new_line}\n#{unchanged_line}\n" }
  let(:old_description) { "#{unchanged_line}\n#{old_line}\n" }

  let(:expected_heading) do
    I18n.t(
      'jobs.timeline_events.description_update_notification.heading',
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
      expect(PublicSlack::MessageService).to receive(:new).and_return(mock_message_service)
      expect(mock_message_service).to receive(:post).with(message: expected_heading, founder: timeline_event.founder)
      expect(PublicSlack::SendFileService).to receive(:new).with(timeline_event.founder, expected_diff, 'diff', expected_filename).and_return(mock_send_file_service)
      expect(mock_send_file_service).to receive(:upload)

      subject.perform_now(timeline_event, old_description)
    end
  end
end
