require 'rails_helper'

describe Targets::DueDateService do
  subject { described_class.new(batch) }

  # create a batch with targets for startups
  let(:batch) { create :batch, start_date: 1.day.ago }
  let(:program_week) { create :program_week, batch: batch, number: 1 }
  let(:target_group) { create :target_group, program_week: program_week }

  let!(:not_expired_target) { create :target, days_to_complete: 14, target_group: target_group }
  let!(:expiring_target) { create :target, days_to_complete: 5, target_group: target_group }
  let!(:expired_target) { create :target, days_to_complete: 0, target_group: target_group }

  describe '#prepare' do
    it 'returns a hash with due dates for each target in the batch' do
      expect(subject.prepare).to eq(
        not_expired_target.id => not_expired_target.due_date.end_of_day,
        expired_target.id => expired_target.due_date.end_of_day,
        expiring_target.id => expiring_target.due_date.end_of_day
      )
    end
  end

  describe '#expiring?' do
    it 'returns expiring status if the target is pending and its due date is within 7 days from now' do
      expect(subject.expiring?(not_expired_target)).to eq(false)
      expect(subject.expiring?(expiring_target)).to eq(true)
      expect(subject.expiring?(expired_target)).to eq(false)
    end
  end

  describe '#expired?' do
    it 'returns expired status if the due date is over' do
      expect(subject.expired?(not_expired_target)).to eq(false)
      expect(subject.expired?(expiring_target)).to eq(false)
      expect(subject.expired?(expired_target)).to eq(true)
    end
  end
end
