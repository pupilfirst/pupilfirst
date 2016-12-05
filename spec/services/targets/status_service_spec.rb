require 'rails_helper'

describe Targets::StatusService do
  subject { described_class.new(target, startup.admin) }

  let(:startup) { create :startup }
  let(:target) { create :target, :with_program_week, role: Target::ROLE_FOUNDER }

  let(:event_for_target) do
    create :timeline_event,
      target: target,
      startup: startup,
      verified_status: TimelineEvent::VERIFIED_STATUS_PENDING
  end

  let(:prerequisite_target) { create :target, role: Target::ROLE_FOUNDER }

  let(:event_for_prerequisite_target) do
    create :timeline_event,
      target: prerequisite_target,
      startup: startup,
      verified_status: TimelineEvent::VERIFIED_STATUS_PENDING
  end

  before do
    target.prerequisite_targets << prerequisite_target
  end

  describe '#status' do
    context 'when the prerequisite target is not completed' do
      it 'returns unavailable' do
        expect(subject.status).to eq(Targets::StatusService::STATUS_UNAVAILABLE)
      end
    end

    context 'when the prerequisite target is completed' do
      it 'returns pending' do
        event_for_prerequisite_target.verify!
        expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
      end
    end

    context 'when the target is completed' do
      it 'returns complete' do
        event_for_target.verify!
        expect(subject.status).to eq(Targets::StatusService::STATUS_COMPLETE)
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
