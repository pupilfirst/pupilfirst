require 'rails_helper'

describe Levels::DeleteService do
  let!(:level_0) { create :level, :zero }
  let!(:level_1) { create :level, :one }
  let!(:level_2) { create :level, :two }
  let!(:level_3) { create :level, :three }

  let!(:startup_l1) { create :startup, level: level_1 }
  let!(:startup_l2) { create :startup, level: level_2 }
  let!(:startup_l3) { create :startup, level: level_3 }

  let!(:target_group_l1) { create :target_group, level: level_1 }
  let!(:target_group_l2) { create :target_group, level: level_2 }
  let!(:target_group_l3) { create :target_group, level: level_3 }

  describe '#execute' do
    context 'when level 3 is deleted' do
      subject { described_class.new(level_3) }

      it 'is merged into level 2' do
        subject.execute

        expect(startup_l3.reload.level).to eq(level_2)
        expect(startup_l2.reload.level).to eq(level_2)
        expect(target_group_l3.reload.level).to eq(level_2)
        expect(target_group_l2.reload.level).to eq(level_2)
      end
    end

    context 'when level 2 is deleted' do
      subject { described_class.new(level_2) }

      it 'is merged into level 1' do
        subject.execute

        expect(startup_l2.reload.level).to eq(level_1)
        expect(startup_l1.reload.level).to eq(level_1)
        expect(target_group_l2.reload.level).to eq(level_1)
        expect(target_group_l1.reload.level).to eq(level_1)
      end

      it 'renumbers level 3 as level 2' do
        subject.execute

        expect(level_3.reload.number).to eq(2)
        expect(startup_l3.reload.level).to eq(level_3)
        expect(target_group_l3.reload.level).to eq(level_3)
      end
    end

    context 'when level 1 is given for deletion' do
      subject { described_class.new(level_1) }

      it 'raises an exception' do
        expect { subject.execute }.to raise_exception('Level 1 cannot be deleted')
      end
    end

    context 'when level 0 is given for deletion' do
      subject { described_class.new(level_0) }

      it 'raises an exception' do
        expect { subject.execute }.to raise_exception('Level 0 cannot be deleted')
      end
    end
  end
end
