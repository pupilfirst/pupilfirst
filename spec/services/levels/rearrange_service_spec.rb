require 'rails_helper'

describe Levels::RearrangeService do
  subject { described_class }

  describe '#move_to' do
    context 'when there are a number of levels' do
      let!(:level_0) { create :level, :zero }
      let!(:level_1) { create :level, :one, course: level_0.course }
      let!(:level_2) { create :level, :two, course: level_0.course }
      let!(:level_3) { create :level, :three, course: level_0.course }
      let!(:level_4) { create :level, :four, course: level_0.course }

      it 'can move a level down' do
        subject.new(level_4).move_to(level_2)

        expect(level_0.reload.number).to eq(0)
        expect(level_1.reload.number).to eq(1)
        expect(level_4.reload.number).to eq(2)
        expect(level_2.reload.number).to eq(3)
        expect(level_3.reload.number).to eq(4)
      end
    end
  end
end
