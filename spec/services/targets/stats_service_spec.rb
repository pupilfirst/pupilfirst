require 'rails_helper'

describe Targets::StatsService do
  subject { described_class.new(target) }

  let(:target) { Target.first }
  let(:prerequisite_target) { Target.second }

  before do
    # Create some startups and startup targets.
    create_list :target, 10, :for_startup
    create_list :startup, 10

    # Configure a prerequisite.
    target.prerequisite_targets << prerequisite_target

    # Mark prerequisite complete for everyone except first startup.
    (Startup.all - [Startup.first]).each do |startup|
      create(:timeline_event, startup: startup, target: prerequisite_target, status: TimelineEvent::STATUS_VERIFIED)
    end

    # Second startup completed the target.
    create(:timeline_event, startup: Startup.second, target: target, status: TimelineEvent::STATUS_VERIFIED)

    # Third startup's submission was rejected.
    create(:timeline_event, startup: Startup.third, target: target, status: TimelineEvent::STATUS_NOT_ACCEPTED)

    # Fourth startup's submission was marked needs improvement.
    create(:timeline_event, startup: Startup.fourth, target: target, status: TimelineEvent::STATUS_NEEDS_IMPROVEMENT)

    # Fifth startup's submission is pending verification.
    create(:timeline_event, startup: Startup.fifth, target: target, status: TimelineEvent::STATUS_PENDING)
  end

  describe '#counts' do
    it 'returns a hash with counts for each status' do
      expect(subject.counts).to eq(
        completed: 1,
        submitted: 1,
        needs_improvement: 1,
        not_accepted: 1,
        pending: 5,
        unavailable: 1
      )
    end
  end

  describe '#unavailable_assignees' do
    it 'returns array of unavailable assignees' do
      expect(subject.unavailable_assignees).to eq([Startup.first])
    end
  end

  describe '#completed_assignees' do
    it 'returns array of completed assignees' do
      expect(subject.completed_assignees).to eq([Startup.second])
    end
  end

  describe '#not_accepted_assignees' do
    it 'returns array of not_accepted assignees' do
      expect(subject.not_accepted_assignees).to eq([Startup.third])
    end
  end

  describe '#needs_improvement_assignees' do
    it 'returns array of needs_improvement assignees' do
      expect(subject.needs_improvement_assignees).to eq([Startup.fourth])
    end
  end

  describe '#submitted_assignees' do
    it 'returns array of submitted assignees' do
      expect(subject.submitted_assignees).to eq([Startup.fifth])
    end
  end

  describe '#pending_assignees' do
    it 'returns array of pending assignees' do
      expect(subject.pending_assignees.sort).to eq(Startup.all.order('id DESC').limit(5).to_a.sort)
    end
  end
end
