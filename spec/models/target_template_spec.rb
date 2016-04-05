require 'rails_helper'

RSpec.describe TargetTemplate, type: :model do
  subject { create :target_template }

  describe '#due_date' do
    context 'when batch is supplied' do
      it 'returns due date, as per batch' do
        batch = create :batch, start_date: 1.year.ago, end_date: 6.months.ago
        expect(subject.due_date(batch: batch)).to eq((batch.start_date + subject.days_from_start).end_of_day)
      end
    end

    context 'when batch is not supplied' do
      let!(:batch) { create :batch, start_date: 3.months.ago, end_date: 3.months.from_now }

      it 'returns due date, as per current batch' do
        expect(subject.due_date).to eq((batch.start_date + subject.days_from_start).end_of_day)
      end
    end
  end
end
