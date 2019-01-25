require 'rails_helper'

describe Targets::AutoVerificationService do
  subject { described_class.new(target, founder_1) }

  let(:course) { create :course }
  let(:level_1) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level_1 }
  let(:target) { create :target, target_group: target_group, role: Target::ROLE_FOUNDER }

  let(:startup) { create :startup, level: level_1 }
  let(:founder_1) { startup.founders.first }
  let(:founder_2) { startup.founders.second }

  describe '#auto_verify' do
    it 'create a timeline event for the founder' do
      subject.auto_verify

      timeline_event = TimelineEvent.last

      expect(timeline_event.target).to eq(target)
      expect(timeline_event.founders).to eq([founder_1])
      expect(timeline_event.description).to eq("Target '#{target.title}' was auto-verified")
      expect(timeline_event.latest).to eq(true)
    end

    context 'if the target role is team' do
      let(:target) { create :target, target_group: target_group, role: Target::ROLE_TEAM }

      it 'creates a timeline event linked to all team members' do
        subject.auto_verify

        timeline_event = TimelineEvent.last

        expect(timeline_event.target).to eq(target)
        expect(timeline_event.founders).to eq(founder_1.startup.founders)
      end
    end
  end
end
