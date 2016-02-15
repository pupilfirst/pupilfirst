require 'rails_helper'

RSpec.describe TimelineEvent, type: :modelr do
  subject { create :timeline_event }

  describe '#verify!' do
    it 'converts event to a verified timeline event' do
      subject.verify!
      subject.reload
      expect(subject.verified_status).to eq(TimelineEvent::VERIFIED_STATUS_VERIFIED)
      expect(subject.verified_at).to be_present
    end

    context 'when timeline event has an attachment' do
      let(:timeline_event_type) { create :timeline_event }
      let(:timeline_event_file) { create :timeline_event_file }

      subject { create :timeline_event, timeline_event_type: timeline_event_type, timeline_event_files: [timeline_event_file] }

      before do
        subject.verify!
      end

      context 'when timeline event is for new deck' do
        let(:timeline_event_type) { create :tet_new_product_deck }

        it 'saves presentation link' do
          expect(subject.startup.presentation_link).to eq(
            Rails.application.routes.url_helpers.download_startup_timeline_event_timeline_event_file_url(
              subject.startup, subject, timeline_event_file
            )
          )
        end
      end

      context 'when timeline event is for new wireframe' do
        let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_NEW_WIREFRAME }

        it 'saves wireframe link' do
          expect(subject.startup.wireframe_link).to eq(
            Rails.application.routes.url_helpers.download_startup_timeline_event_timeline_event_file_url(
              subject.startup, subject, timeline_event_file
            )
          )
        end
      end

      context 'when timeline event is for new prototype' do
        let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_NEW_PROTOTYPE }

        it 'saves prototype link' do
          expect(subject.startup.prototype_link).to eq(
            Rails.application.routes.url_helpers.download_startup_timeline_event_timeline_event_file_url(
              subject.startup, subject, timeline_event_file
            )
          )
        end
      end

      context 'when timeline event is for new video' do
        # Check whether regular links work as well.
        subject { create :timeline_event_with_links, timeline_event_type: timeline_event_type }
        let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_NEW_VIDEO }

        it 'saves link to product video' do
          expect(subject.startup.product_video).to eq('https://sv.co/private')
        end
      end

      context 'when timeline event is for new resume' do
        let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_RESUME_SUBMISSION }

        it 'saves resume link' do
          expect(subject.user.resume_url).to eq(
            Rails.application.routes.url_helpers.download_startup_timeline_event_timeline_event_file_url(
              subject.startup, subject, timeline_event_file
            )
          )
        end
      end
    end
  end
end
