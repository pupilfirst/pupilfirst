require 'rails_helper'

describe Targets::StatusService do
  subject { described_class.new(target, startup.admin) }

  let(:startup) { create :startup }
  let(:target) { create :target, :with_program_week, role: Target::ROLE_FOUNDER, days_to_complete: 60, week_number: 2 }
  let(:prerequisite_target) { create :target, role: Target::ROLE_FOUNDER }

  let!(:event_for_prerequisite_target) do
    create :timeline_event,
      target: prerequisite_target,
      startup: startup
  end

  before do
    target.prerequisite_targets << prerequisite_target
  end

  describe '#status' do
    context 'when the target has no associated timeline event' do
      context 'when prerequisites are not complete' do
        it 'returns unavailable' do
          event_for_prerequisite_target.update!(verified_status: TimelineEvent::VERIFIED_STATUS_PENDING)
          expect(subject.status).to eq(Targets::StatusService::STATUS_UNAVAILABLE)
        end
      end

      context 'when prerequisites are complete' do
        before do
          event_for_prerequisite_target.update!(verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED)
        end

        it 'returns expired if the due date is over' do
          target.update!(days_to_complete: 0)
          expect(subject.status).to eq(Targets::StatusService::STATUS_EXPIRED)
        end

        it 'returns pending if the due date is not over' do
          target.update!(days_to_complete: 60)
          expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
        end
      end
    end

    context 'when the target has an associated timeline event' do
      let!(:event_for_target) do
        create :timeline_event,
          target: target,
          startup: startup
      end

      before do
        # mark prerequisite target complete
        event_for_prerequisite_target.update!(verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED)
      end

      it 'returns submitted if the event is pending verification' do
        event_for_target.update!(verified_status: TimelineEvent::VERIFIED_STATUS_PENDING)
        expect(subject.status).to eq(Targets::StatusService::STATUS_SUBMITTED)
      end

      it 'returns complete if the event is verified' do
        event_for_target.update!(verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED)
        expect(subject.status).to eq(Targets::StatusService::STATUS_COMPLETE)
      end

      it 'returns needs_improvement if the event is marked needs_improvement' do
        event_for_target.update!(verified_status: TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT)
        expect(subject.status).to eq(Targets::StatusService::STATUS_NEEDS_IMPROVEMENT)
      end
    end
  end

  describe '#pending_prerequisites' do
    context 'when the prerequisite is not completed' do
      it 'returns an array containing the prerequisite' do
        expect(subject.pending_prerequisites).to eq([prerequisite_target])
      end
    end

    context 'when the prerequisite is completed' do
      it 'returns an empty array' do
        event_for_prerequisite_target.verify!
        expect(subject.pending_prerequisites).to eq([])
      end
    end
  end

  describe '#completed_prerequisites' do
    context 'when the prerequisite is not completed' do
      it 'returns an empty array' do
        expect(subject.completed_prerequisites).to eq([])
      end
    end

    context 'when the prerequisite is completed' do
      it 'returns an array containing the prerequisite' do
        event_for_prerequisite_target.verify!
        expect(subject.completed_prerequisites).to eq([prerequisite_target])
      end
    end
  end
end
