require 'rails_helper'

describe Founders::TargetStatusService do
  subject { described_class.new(startup.team_lead) }

  # Let's create an school with 3 levels...
  let(:school) { create :school }
  let(:level_1) { create :level, :one, school: school }
  let(:level_2) { create :level, :two, school: school }
  let(:level_3) { create :level, :three, school: school }

  # ... and have a few target groups in each level, including milestone ones.
  let(:l_1_target_group_1) { create :target_group, level: level_1 }
  let(:l_1_target_group_2) { create :target_group, level: level_1, milestone: true }
  let(:l_2_target_group_1) { create :target_group, level: level_2 }
  let(:l_2_target_group_2) { create :target_group, level: level_2, milestone: true }
  let(:l_3_target_group) { create :target_group, level: level_3, milestone: true }

  # Let's have a faculty and a startup in Level 2
  let(:faculty) { create :faculty }
  let(:startup) { create :startup, level: level_2 }
  let(:founder) { startup.team_lead }

  # founder has passed l_1_target_1
  let!(:l_1_target_1) { create :target, target_group: l_1_target_group_1 }
  let!(:te_1) { create :timeline_event, founder: founder, target: l_1_target_1, passed_at: 10.days.ago }

  # founder has failed l_1_target_2
  let!(:l_1_target_2) { create :target, target_group: l_1_target_group_1 }
  let!(:te_2) { create :timeline_event, founder: founder, target: l_1_target_2, evaluator: faculty }

  # founder has submitted milestone l_1_target_3
  let!(:l_1_target_3) { create :target, target_group: l_1_target_group_2 }
  let!(:te_3) { create :timeline_event, founder: founder, target: l_1_target_3 }

  # founder has a pending l_2_target_1 with a passed prerequisite (l_1_target_1) and an archived_prerequisite
  let!(:l_2_target_1) { create :target, target_group: l_2_target_group_1 }
  let!(:archived_prerequisite) { create :target, target_group: l_2_target_group_1, archived: true }

  # founder has a l_2_target_2 which is pre-requisite locked by l_2_target_1
  let!(:l_2_target_2) { create :target, target_group: l_2_target_group_1 }

  # founder has a milestone l_2_target_3 which is milestone-locked by l_1_target_3 and prerequisite-locked by l_1_target_1(milestone-lock takes priority over prerequisite-lock)
  let!(:l_2_target_3) { create :target, target_group: l_2_target_group_2 }

  # founder has a level-locked milestone l_3_target (level-lock takes priority over milestone-lock)
  let!(:l_3_target) { create :target, target_group: l_3_target_group }

  before do
    l_2_target_1.prerequisite_targets << [l_1_target_1, archived_prerequisite]
    l_2_target_2.prerequisite_targets << l_2_target_1
    l_2_target_3.prerequisite_targets << l_2_target_1

    # TODO: Remove explicit creation of submission records once we have the TimelineEvent#after_create hook merge in.
    TimelineEvent.all.each do |timeline_event|
      LatestSubmissionRecord.create!(timeline_event: timeline_event, founder: founder, target: timeline_event.target)
    end
  end

  describe '#status' do
    it 'returns the right status for all timeline events' do
      expect(subject.status(l_1_target_1.id)).to eq(Targets::StatusService::STATUS_PASSED)
      expect(subject.status(l_1_target_2.id)).to eq(Targets::StatusService::STATUS_FAILED)
      expect(subject.status(l_1_target_3.id)).to eq(Targets::StatusService::STATUS_SUBMITTED)
      expect(subject.status(l_2_target_1.id)).to eq(Targets::StatusService::STATUS_PENDING)
      expect(subject.status(l_2_target_2.id)).to eq(Targets::StatusService::STATUS_PREREQUISITE_LOCKED)
      expect(subject.status(l_2_target_3.id)).to eq(Targets::StatusService::STATUS_MILESTONE_LOCKED)
      expect(subject.status(l_3_target.id)).to eq(Targets::StatusService::STATUS_LEVEL_LOCKED)
    end
  end

  describe '#submitted_at' do
    it 'returns the event submission datetime for submitted, passed & failed targets' do
      expect(subject.submitted_at(l_1_target_1.id)).to eq(te_1.created_at.iso8601)
      expect(subject.submitted_at(l_1_target_2.id)).to eq(te_2.created_at.iso8601)
      expect(subject.submitted_at(l_1_target_3.id)).to eq(te_3.created_at.iso8601)
    end

    it 'returns nil for all unsubmitted targets' do
      expect(subject.submitted_at(l_2_target_1.id)).to be_nil
      expect(subject.submitted_at(l_2_target_2.id)).to be_nil
      expect(subject.submitted_at(l_2_target_3.id)).to be_nil
      expect(subject.submitted_at(l_3_target.id)).to be_nil
    end
  end

  describe '#prerequisite_targets' do
    it 'returns all active prerequisite ids for all targets with prerequisites' do
      expect(subject.prerequisite_targets(l_2_target_1.id)).to eq([{ 'id' => l_1_target_1.id }])
      expect(subject.prerequisite_targets(l_2_target_2.id)).to eq([{ 'id' => l_2_target_1.id }])
      expect(subject.prerequisite_targets(l_2_target_3.id)).to eq([{ 'id' => l_2_target_1.id }])
    end

    it 'returns [] for all targets without prerequisites' do
      expect(subject.prerequisite_targets(l_1_target_1.id)).to eq([])
      expect(subject.prerequisite_targets(l_1_target_2.id)).to eq([])
      expect(subject.prerequisite_targets(l_1_target_3.id)).to eq([])
      expect(subject.prerequisite_targets(l_3_target.id)).to eq([])
    end
  end

  describe '#evaluation_criteria' do
    it 'returns the evaluation critera assigned to each target' do
      pending 'add evaluation criteria and test'
    end
  end
end
