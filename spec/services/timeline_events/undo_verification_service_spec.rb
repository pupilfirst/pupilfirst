require 'rails_helper'

describe TimelineEvents::UndoVerificationService do
  subject { described_class.new(timeline_event) }

  let(:timeline_event) { create :timeline_event }

  describe '#execute' do
    context 'when the timeline event is pending' do
      it 'raises an error' do
        expect { subject.execute }.to raise_error("TimelineEvent ##{timeline_event.id} is pending, and cannot be processed")
      end
    end

    context 'when the timeline event has status other than pending' do
      let(:timeline_event_type) { create :timeline_event_type }
      let(:timeline_event) { create :timeline_event, :verified, timeline_event_type: timeline_event_type }

      it 'resets the status to pending' do
        expect { subject.execute }.to change { timeline_event.reload.status }
          .from(TimelineEvent::STATUS_VERIFIED).to(TimelineEvent::STATUS_PENDING)
      end

      context 'when timeline event was awarded karma points' do
        before do
          create :karma_point, founder: timeline_event.founder, source: timeline_event
        end

        it 'deletes karma points' do
          expect { subject.execute }.to change { timeline_event.reload.karma_point.present? }
            .from(true).to(false)
        end
      end

      context 'when timeline event updated startup profile' do
        let(:timeline_event) { create :timeline_event, status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT, timeline_event_type: timeline_event_type }

        before do
          timeline_event.startup.update!(
            presentation_link: 'http://example.com/presentation',
            wireframe_link: 'http://example.com/wireframe',
            prototype_link: 'http://example.com/prototype',
            product_video_link: 'http://example.com/video'
          )
        end

        context 'when the timeline event updated presentation link' do
          let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_NEW_DECK }

          it 'removes the presentation link from startup profile' do
            expect { subject.execute }.to change { timeline_event.reload.startup.presentation_link }
              .from('http://example.com/presentation').to(nil)
          end
        end

        context 'when the timeline event updated wireframe link' do
          let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_NEW_WIREFRAME }

          it 'removes the link from startup profile' do
            expect { subject.execute }.to change { timeline_event.reload.startup.wireframe_link }
              .from('http://example.com/wireframe').to(nil)
          end
        end

        context 'when the timeline event updated prototype link' do
          let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_NEW_PROTOTYPE }

          it 'removes the link from startup profile' do
            expect { subject.execute }.to change { timeline_event.reload.startup.prototype_link }
              .from('http://example.com/prototype').to(nil)
          end
        end

        context 'when the timeline event updated product video link' do
          let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_NEW_VIDEO }

          it 'removes the link from startup profile' do
            expect { subject.execute }.to change { timeline_event.reload.startup.product_video_link }
              .from('http://example.com/video').to(nil)
          end
        end
      end

      context "when the startup's timeline_updated_on was changed" do
        let(:old_event_on) { 1.month.ago.to_date }

        before do
          create :timeline_event, :verified, founder: timeline_event.founder, startup: timeline_event.startup, event_on: old_event_on
          timeline_event.startup.update!(timeline_updated_on: timeline_event.event_on)
        end

        it 'recomputes the value of timeline_updated_on' do
          expect { subject.execute }.to change { timeline_event.reload.startup.timeline_updated_on }
            .from(timeline_event.event_on).to(old_event_on)
        end
      end

      context "when the timeline event verification updated founder's resume" do
        let(:timeline_event_type) { create :timeline_event_type, key: TimelineEventType::TYPE_RESUME_SUBMISSION }

        before do
          timeline_event.founder.update!(
            resume_file: create(:timeline_event_file),
            resume_url: 'http://www.example.com/resume'
          )
        end

        context 'if the timeline event was not verified' do
          let(:timeline_event) { create :timeline_event, status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT, timeline_event_type: timeline_event_type }

          it 'does nothing' do
            subject.execute
            founder = timeline_event.reload.founder
            expect(founder.resume_file).not_to eq(nil)
            expect(founder.resume_url).to eq('http://www.example.com/resume')
          end
        end

        context 'if the timeline event was verified' do
          it 'removes link to resume from founder profile' do
            subject.execute
            founder = timeline_event.reload.founder
            expect(founder.resume_file).to eq(nil)
            expect(founder.resume_url).to eq(nil)
          end
        end
      end
    end
  end
end
