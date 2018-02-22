require 'rails_helper'

describe Targets::OverlayDetailsService do
  subject { described_class.new(target, founder_1) }

  let(:target) { create :target, :for_founders }
  let(:startup) { create :startup }
  let(:founder_1) { startup.founders.first }
  let(:founder_2) { startup.founders.second }
  let!(:timeline_event) { create :timeline_event_with_links, target: target, founder: founder_1, status: TimelineEvent::STATUS_VERIFIED }
  let(:faculty) { create :faculty }
  let(:faculty_feedback) { create :startup_feedback, timeline_event: timeline_event, faculty: faculty, startup: startup }

  describe '#all_details' do
    it 'returns the founder statuses, latest event and latest feedback' do
      founder_statuses = [{ founder_1.id => :complete }, { founder_2.id => :pending }]

      event = {
        description: timeline_event.description,
        event_on: timeline_event.event_on,
        title: timeline_event.title,
        days_elapsed: timeline_event.days_elapsed,
        attachments: [{ type: 'link', title: 'Private URL', url: 'https://sv.co/private' }, { type: 'link', title: 'Public URL', url: 'https://google.com' }]
      }

      feedback = {
        facultyName: faculty.name,
        feedback: faculty_feedback.feedback,
        facultySlackUsername: faculty.slack_username,
        facultyImageUrl: faculty.image_url
      }

      all_details = subject.all_details

      expect(all_details).to include(:founderStatuses, :latestEvent, :latestFeedback)
      expect(all_details[:founderStatuses]).to match_array(founder_statuses)
      expect(all_details[:latestEvent]).to eq(event)
      expect(all_details[:latestFeedback]).to eq(feedback)
    end
  end
end
