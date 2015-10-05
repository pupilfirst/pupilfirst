require 'rails_helper'

describe Target do
  let(:subject) { create :target }

  describe '#pending?' do
    context 'when target is in pending status' do
      it 'returns true' do
        expect(subject.pending?).to eq(true)
      end
    end

    context 'when target is not in pending status' do
      let(:subject) { create :target, status: 'done' }

      it 'returns false' do
        expect(subject.pending?).to eq(false)
      end
    end
  end
end
