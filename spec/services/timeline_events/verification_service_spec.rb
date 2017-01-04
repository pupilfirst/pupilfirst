require 'rails_helper'

describe TimelineEvents::VerificationService do
  subject { described_class.new(timeline_event) }

  let(:timeline_event) { create :timeline_event }
  let(:karma_point) { create :karma_point, points: 50 }
  let(:target) { create :target, points_earnable: 10 }

  before do
    # stub out vocalist notifications
    allow(TimelineEventVerificationNotificationJob).to receive(:perform_later).and_return(true)

    # add an initial dummy karma point for testing
    karma_point.update!(source: timeline_event)
  end

  describe '#update_status' do
    context 'when the timeline event is not associated to a target' do
      context 'when asked to mark event as verified' do
        it 'marks the event verified and adds appropriate karma points' do
          subject.update_status(TimelineEvent::VERIFIED_STATUS_VERIFIED, points: 10)

          timeline_event.reload
          expect(timeline_event.verified?).to eq(true)
          expect(timeline_event.karma_point.points).to eq(10)
        end
      end

      context 'when asked to mark event as not accepted' do
        it 'marks the event not accepted and deletes associated karma point' do
          subject.update_status(TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED)

          timeline_event.reload
          expect(timeline_event.not_accepted?).to eq(true)
          expect(timeline_event.karma_point).to eq(nil)
        end
      end
    end

    context 'when the timeline event is associated with a target' do
      before do
        timeline_event.update!(target: target)
      end

      context 'when asked to mark event as verified and graded as wow' do
        it 'marks the event verified and adds appropriate karma points' do
          subject.update_status(TimelineEvent::VERIFIED_STATUS_VERIFIED, grade: TimelineEvent::GRADE_WOW)

          timeline_event.reload
          expect(timeline_event.verified?).to eq(true)
          expect(timeline_event.karma_point.points).to eq(20)
        end
      end

      context 'when asked to mark event as needs improvement' do
        it 'marks the event as needs improvement and add minimum karma point earnable for target' do
          subject.update_status(TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT)

          timeline_event.reload
          expect(timeline_event.needs_improvement?).to eq(true)
          expect(timeline_event.karma_point.points).to eq(10)
        end
      end
    end
  end
end
