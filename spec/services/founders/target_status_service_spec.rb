require 'rails_helper'

describe Founders::TargetStatusService do
  subject { described_class.new(founder) }

  let(:level_zero) { create :level, :zero }
  let(:level_one) { create :level, :one }
  let(:level_two) { create :level, :two }
  let!(:startup) { create :startup, level: level_zero }
  let(:founder) { create :founder }
  let(:co_founder) { create :founder }

  let!(:target_group) { create :target_group, level: level_zero }
  let!(:founder_target) { create :target, :for_founders, target_group: target_group }
  let!(:startup_target) { create :target, :for_startup, target_group: target_group }
  let!(:founder_session) { create :target, target_group: target_group, session_at: 1.month.ago }

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
      it 'returns :unavailable' do
        founder_target.prerequisite_targets << startup_target
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_UNAVAILABLE)
      end

      context 'when the target has been completed with a timeline event' do
        it 'returns :unavailable' do
          founder_event.update!(target: founder_target, status: TimelineEvent::STATUS_VERIFIED)
          founder_target.prerequisite_targets << startup_target
          expect(subject.status(founder_target.id)).to eq(Target::STATUS_UNAVAILABLE)
        end
      end
    end

    context 'when the target has a completed prerequisite' do
      it 'returns :pending' do
        founder_target.prerequisite_targets << startup_target
        co_founder_event.update!(target: startup_target, status: TimelineEvent::STATUS_VERIFIED)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_PENDING)
      end
    end

    context 'when the startup is at a higher level' do
      let!(:startup) { create :startup, level: level_two }
      let!(:level_zero_target_group) { create :target_group, level: level_zero }
      let!(:level_one_target_group) { create :target_group, level: level_one }
      let!(:level_two_target_group) { create :target_group, level: level_two }
      let!(:level_zero_target) { create :target, :for_founders, target_group: level_zero_target_group }
      let!(:level_one_target) { create :target, :for_founders, target_group: level_one_target_group }
      let!(:level_two_target) { create :target, :for_founders, target_group: level_two_target_group }
      let!(:founder_session) { create :target, target_group: level_one_target_group, session_at: 1.month.ago }

      # This ensures that a edge-case situation does not result in a crash: https://trello.com/c/F7oRFaPf
      context 'when there is an incomplete prerequisite in level 0 for a completed target' do
        before do
          level_zero_target.prerequisite_targets << create(:target, :for_founders, target_group: level_zero_target_group)
          level_zero_target.save!
        end

        it 'should return the status for a level 1 target' do
          founder_event.update!(target: level_zero_target, status: TimelineEvent::STATUS_VERIFIED)

          expect(subject.status(level_one_target.id)).to eq(:pending)
        end
      end
    end
  end
end
