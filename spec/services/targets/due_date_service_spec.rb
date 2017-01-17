require 'rails_helper'

describe Targets::DueDateService do
  subject { described_class.new(batch) }

  # create a batch with targets for startups
  let!(:batch) { create :batch, :just_started, :with_startups, :with_targets_for_startups }
  # select sample targets for testing
  let(:target_1) { Target.first }
  let(:target_2) { Target.last }

  describe '#prepare' do
    it 'returns a hash with due dates for each target in the batch' do
      targets_due_dates = Target.all.each_with_object({}) do |target, hash|
        hash[target.id] = target.due_date.end_of_day
      end
      expect(subject.prepare) .to eq(targets_due_dates)
    end
  end

  context 'when target expiry status needs to be checked' do
    before do
      # make target1 as expired and target2 as pending with less than a week to expire
      target_1.update!(days_to_complete: 0)
      target_2.update!(days_to_complete: 5)
      subject.prepare
    end
    describe '#expired?' do
      it 'returns expired status if the due date is over' do
        expect(subject.expired?(target_1)).to eq(true)
        expect(subject.expired?(target_2)).to eq(false)
      end
    end

    describe '#expiring?' do
      it 'returns expiring status if the target is pending and its due date is within 7 days from now' do
        expect(subject.expiring?(target_1)).to eq(false)
        expect(subject.expiring?(target_2)).to eq(true)
      end
    end
  end
end
