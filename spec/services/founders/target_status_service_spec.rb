require 'rails_helper'

describe Founders::TargetStatusService do
  subject { described_class.new(founder) }

  let(:school) { create :school }
  let(:level_zero) { create :level, :zero, school: school }
  let(:level_one) { create :level, :one, school: school }
  let(:level_two) { create :level, :two, school: school }
  let!(:startup) { create :startup, level: level_zero }
  let(:founder) { create :founder }
  let(:co_founder) { create :founder }

  let!(:target_group) { create :target_group, level: level_zero }
  let!(:level_2_target_group) { create :target_group, level: level_two }
  let!(:founder_target) { create :target, :for_founders, target_group: target_group }
  let!(:startup_target) { create :target, :for_startup, target_group: target_group }
  let!(:level_2_target) { create :target, :for_startup, target_group: level_2_target_group }
  let!(:founder_session) { create :target, target_group: target_group, session_at: 1.month.ago }

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
      let!(:founder_event) { create :timeline_event, target: founder_target, founder: founder, startup: startup }

      it 'returns :submitted' do
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_SUBMITTED)
      end
    end

    context 'when the founder target has a verified submission' do
      let(:founder_event) { create :timeline_event, target: founder_target, founder: founder, startup: startup }

      it 'returns :complete' do
        founder_event.update!(status: TimelineEvent::STATUS_VERIFIED)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_COMPLETE)
      end
    end

    context 'when the founder target has a needs_improvement submission' do
      let(:founder_event) { create :timeline_event, target: founder_target, founder: founder, startup: startup }

      it 'returns :needs_improvement' do
        founder_event.update!(status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_NEEDS_IMPROVEMENT)
      end
    end

    context 'when the founder target has a not_accepted submission' do
      let(:founder_event) { create :timeline_event, target: founder_target, founder: founder, startup: startup }

      it 'returns :not_accepted' do
        founder_event.update!(status: TimelineEvent::STATUS_NOT_ACCEPTED)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_NOT_ACCEPTED)
      end
    end

    context 'when the founder has multiple submissions for target' do
      let(:founder_event) { create :timeline_event, target: founder_target, founder: founder, startup: startup }
      let(:founder_event_2) { create :timeline_event, target: founder_target, founder: founder, startup: startup }

      it 'returns status based on the latest submission' do
        founder_event.update!(status: TimelineEvent::STATUS_NOT_ACCEPTED, created_at: 2.days.ago)
        founder_event_2.update!(status: TimelineEvent::STATUS_VERIFIED, created_at: 1.day.ago)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_COMPLETE)
      end
    end

    context 'when the co-founder has completed a startup target' do
      let(:co_founder_event) { create :timeline_event, target: startup_target, founder: co_founder, startup: startup }

      it 'returns :complete' do
        co_founder_event.update!(status: TimelineEvent::STATUS_VERIFIED)
        expect(subject.status(startup_target.id)).to eq(Target::STATUS_COMPLETE)
      end
    end

    context 'when the target has a pending prerequisite' do
      it 'returns :unavailable' do
        founder_target.prerequisite_targets << startup_target
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_UNAVAILABLE)
      end

      context 'when the target has been completed with a timeline event' do
        let(:founder_event) { create :timeline_event, target: founder_target, founder: founder, startup: startup }

        it 'returns :unavailable' do
          founder_event.update!(status: TimelineEvent::STATUS_VERIFIED)
          founder_target.prerequisite_targets << startup_target
          expect(subject.status(founder_target.id)).to eq(Target::STATUS_UNAVAILABLE)
        end
      end
    end

    context 'when the target has a completed prerequisite' do
      let(:founder_event) { create :timeline_event, target: founder_target, founder: founder, startup: startup }
      let(:co_founder_event) { create :timeline_event, target: startup_target, founder: co_founder, startup: startup }

      it 'returns :pending' do
        founder_target.prerequisite_targets << startup_target
        co_founder_event.update!(status: TimelineEvent::STATUS_VERIFIED)
        expect(subject.status(founder_target.id)).to eq(Target::STATUS_PENDING)
      end
    end

    context 'when the target is from a higher level than the startup' do
      it 'returns :level_locked' do
        expect(subject.status(level_2_target.id)).to eq(Target::STATUS_LEVEL_LOCKED)
      end
    end

    context 'when the startup is at a higher level' do
      let!(:startup) { create :startup, level: level_two }
      let!(:level_zero_target_group) { create :target_group, level: level_zero }
      let!(:level_one_target_group) { create :target_group, level: level_one, milestone: true }
      let!(:level_two_target_group) { create :target_group, level: level_two, milestone: true }
      let!(:level_zero_target) { create :target, :for_founders, target_group: level_zero_target_group }
      let!(:level_one_target) { create :target, :for_founders, target_group: level_one_target_group }
      let!(:level_two_target) { create :target, :for_founders, target_group: level_two_target_group }
      let!(:founder_session) { create :target, target_group: level_one_target_group, session_at: 1.month.ago }

      # This ensures that a edge-case situation does not result in a crash: https://trello.com/c/F7oRFaPf
      context 'when there is an incomplete prerequisite in level 0 for a completed target' do
        let!(:founder_event) { create :timeline_event, target: level_zero_target, founder: founder, startup: startup }
        before do
          level_zero_target.prerequisite_targets << create(:target, :for_founders, target_group: level_zero_target_group)
          level_zero_target.save!
        end

        it 'should return the status for a level 1 target' do
          founder_event.update!(status: TimelineEvent::STATUS_VERIFIED)

          expect(subject.status(level_one_target.id)).to eq(:pending)
        end
      end

      context 'when there is an incomplete milestone in the previous level' do
        it 'returns :pending_milestone for milestones in the current level' do
          expect(subject.status(level_two_target.id)).to eq(Target::STATUS_PENDING_MILESTONE)
        end
      end

      context 'when all mielstone targets in the previous level is complete' do
        let!(:founder_event) { create :timeline_event, target: level_one_target, founder: founder, startup: startup }
        let!(:founder_event_2) { create :timeline_event, target: founder_session, founder: founder, startup: startup }
        it 'returns :pending for the milestones in the current level' do
          founder_event.update!(status: TimelineEvent::STATUS_VERIFIED)
          founder_event_2.update!(status: TimelineEvent::STATUS_VERIFIED)
          expect(subject.status(level_two_target.id)).to eq(Target::STATUS_PENDING)
        end
      end
    end
  end
end
