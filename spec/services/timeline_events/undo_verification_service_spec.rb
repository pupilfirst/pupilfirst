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
      let(:timeline_event) { create :timeline_event, :verified }

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
    end
  end
end
