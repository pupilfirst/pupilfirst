require 'rails_helper'

describe Founders::TargetsFilterService do
  subject { described_class.new(founder) }

  # create a batch with targets for a founder
  let(:batch) { create :batch, start_date: 1.day.ago }
  let(:startup) { create :startup, batch: batch }
  let(:founder) { create :founder, startup: startup }
  let(:program_week) { create :program_week, batch: batch, number: 1 }
  let(:target_group) { create :target_group, program_week: program_week }

  let!(:expiring_target) { create :target, days_to_complete: 5, target_group: target_group }
  let!(:expired_target) { create :target, days_to_complete: 0, target_group: target_group }
  let!(:needs_improvement_target) { create :target, days_to_complete: 20, target_group: target_group }
  let!(:not_accepted_target) { create :target, days_to_complete: 20, target_group: target_group }

  describe '#filter' do
    before do
      # Create timeline events and set the verified status as required
      create(:timeline_event, founder: founder, startup: startup, target: needs_improvement_target, verified_status: TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT)
      create(:timeline_event, founder: founder, startup: startup, target: not_accepted_target, verified_status: TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED)
    end

    it 'returns targets based on the target filter specified' do
      expect(subject.filter('expires_soon')[0].model).to eq(expiring_target)
      expect(subject.filter('expired')[0].model).to eq(expired_target)
      expect(subject.filter('needs_improvement')[0].model).to eq(needs_improvement_target)
      expect(subject.filter('not_accepted')[0].model).to eq(not_accepted_target)
      expect { subject.filter('undefined_filter') }.to raise_error(RuntimeError, /Unexpected filter value 'undefined_filter'/)
    end
  end
end
