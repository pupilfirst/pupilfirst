require 'rails_helper'

RSpec.describe Batch, type: :model do
  subject { create :batch }

  describe '#display_name' do
    it 'returns number followed by name' do
      expect(subject.display_name).to eq("##{subject.batch_number} #{subject.theme}")
    end
  end

  describe '#present_week_number' do
    context 'when batch has started' do
      it 'returns week number' do
        expect(subject.present_week_number).to eq(5)
      end
    end

    context 'when batch has not started' do
      subject { create :batch, start_date: 1.day.from_now }

      it 'returns nil' do
        expect(subject.present_week_number).to eq(nil)
      end
    end
  end
end
