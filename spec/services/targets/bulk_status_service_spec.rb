require 'rails_helper'

describe Targets::BulkStatusService do
  subject { described_class.new(founder) }

  let(:level_zero) { create :level, :zero }
  let!(:startup) { create :startup, level: level_zero }
  let(:founder) { create :founder }
  let(:co_founder) { create :founder }

  let!(:target_group) { create :target_group, level: level_zero }
  let!(:founder_target) { create :target, :for_founders, target_group: target_group }
  let!(:startup_target) { create :target, :for_startup, target_group: target_group }
  let!(:founder_chore) { create :target, target_group: nil, chore: true, level: level_zero }

  let!(:founder_event) { create :timeline_event, founder: founder, startup: startup }
  let!(:founder_event_2) { create :timeline_event, founder: founder, startup: startup }
  let!(:co_founder_event) { create :timeline_event, founder: co_founder, startup: startup }

  before do
    startup.founders << [founder, co_founder]
  end

  describe '#status' do
    context 'when there is no event submission for the target' do
      it 'returns :pending' do
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_PENDING)
        expect(subject.status(startup_target.id)).to eq(Target::STATUS_PENDING)
      end
    end

    context 'when the founder target has a event pending verification' do
      it 'returns :submitted' do
        founder_event.update!(target: founder_target)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_SUBMITTED)
      end
    end

    context 'when the founder target has a verified submission' do
      it 'returns :complete' do
        founder_event.update!(target: founder_target, status: TimelineEvent::STATUS_VERIFIED)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_COMPLETE)
      end
    end

    context 'when the founder target has a needs_improvement submission' do
      it 'returns :needs_improvement' do
        founder_event.update!(target: founder_target, status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_NEEDS_IMPROVEMENT)
      end
    end

    context 'when the founder target has a not_accepted submission' do
      it 'returns :not_accepted' do
        founder_event.update!(target: founder_target, status: TimelineEvent::STATUS_NOT_ACCEPTED)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_NOT_ACCEPTED)
      end
    end

    context 'when the founder has multiple submissions for target' do
      it 'returns status based on the latest submission' do
        founder_event.update!(target: founder_target, status: TimelineEvent::STATUS_NOT_ACCEPTED, created_at: 2.days.ago)
        founder_event_2.update!(target: founder_target, status: TimelineEvent::STATUS_VERIFIED, created_at: 1.day.ago)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_COMPLETE)
      end
    end

    context 'when the co-founder has completed a startup target' do
      it 'returns :complete' do
        co_founder_event.update!(target: startup_target, status: TimelineEvent::STATUS_VERIFIED)
        expect(subject.status(startup_target.id)).to eq(Target::STATUS_COMPLETE)
      end
    end

    context 'when the target has a pending prerequisite' do
      it 'returns :un_available' do
        founder_target.prerequisite_targets << startup_target
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_UNAVAILABLE)
      end
    end

    context 'when the target has a completed prerequisite' do
      it 'returns :pending' do
        founder_target.prerequisite_targets << startup_target
        co_founder_event.update!(target: startup_target, status: TimelineEvent::STATUS_VERIFIED)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_PENDING)
      end
    end

    context 'when the startup iteration is different from a vanilla targets event iteration' do
      it 'ignores previous submission and returns :pending' do
        founder_event.update!(target: founder_target, status: TimelineEvent::STATUS_VERIFIED)
        startup.update!(iteration: 2)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_PENDING)
      end
    end

    context 'when the startup iteration is different from a chores event iteration' do
      it 'returns status from previous iteration' do
        founder_event.update!(target: founder_chore, status: TimelineEvent::STATUS_VERIFIED)
        startup.update!(iteration: 2)
        expect(subject.status(founder_chore.id)).to eq(Target::STATUS_COMPLETE)
      end
    end
  end
end
