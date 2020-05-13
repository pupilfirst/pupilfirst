require 'rails_helper'

describe Levels::MergeService do
  subject { described_class }

  let!(:level_0) { create :level, :zero }
  let!(:level_1) { create :level, :one, course: level_0.course }
  let!(:level_2) { create :level, :two, course: level_0.course }
  let!(:level_3) { create :level, :three, course: level_0.course }

  let!(:startup_l1) { create :startup, level: level_1 }
  let!(:startup_l2) { create :startup, level: level_2 }
  let!(:startup_l3) { create :startup, level: level_3 }

  let!(:target_group_l1) { create :target_group, level: level_1 }
  let!(:target_group_l2) { create :target_group, level: level_2 }
  let!(:target_group_l3) { create :target_group, level: level_3 }

  RSpec.shared_examples "merges a level" do |level_number, merge_into_number|
    let(:level_to_delete) { Level.find_by(number: level_number) }
    let(:level_to_merge_into) { Level.find_by(number: merge_into_number) }

    it 'links teams and target groups in level marked for deletion to another level' do
      chosen_level_startups = level_to_delete.startups.pluck(:id)
      chosen_level_target_groups = level_to_delete.target_groups.pluck(:id)

      subject.new(level_to_delete).merge_into(level_to_merge_into)

      expect(level_to_merge_into.startups.where(id: chosen_level_startups).count).to eq(chosen_level_startups.count)
      expect(level_to_merge_into.target_groups.where(id: chosen_level_target_groups).count).to eq(chosen_level_target_groups.count)
    end

    it 'removes entry for the chosen level' do
      subject.new(level_to_delete).merge_into(level_to_merge_into)

      expect { level_to_delete.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe '#merge_into' do
    context 'when level 3 is merged with level 2' do
      include_examples 'merges a level', 3, 2
    end

    context 'when level 2 is merged with level 1' do
      include_examples 'merges a level', 2, 1

      it 'renumbers level 3 as level 2' do
        subject.new(level_2).merge_into(level_1)

        # Number should have changed...
        expect(level_3.reload.number).to eq(2)

        # ...but links should be preserved.
        expect(startup_l3.reload.level).to eq(level_3)
        expect(target_group_l3.reload.level).to eq(level_3)
      end
    end

    context 'when level 1 is merged with level 3' do
      include_examples 'merges a level', 1, 3

      it 'renumbers level 2 as 1, and level 3 as 2' do
        subject.new(level_1).merge_into(level_3)

        # Numbers should have changed.
        expect(level_2.reload.number).to eq(1)
        expect(level_3.reload.number).to eq(2)

        # Links should be preserved.
        expect(startup_l1.reload.level).to eq(level_3)
        expect(target_group_l1.reload.level).to eq(level_3)
      end
    end

    context 'when level 0 is merged with level 1' do
      include_examples 'merges a level', 0, 1

      it 'does not change any level numbers' do
        subject.new(level_0).merge_into(level_1)

        # Numbers should not have changed.
        expect(level_1.reload.number).to eq(1)
        expect(level_2.reload.number).to eq(2)
        expect(level_3.reload.number).to eq(3)
      end
    end

    it 'does not allow merging of any level into level 0' do
      expect do
        subject.new(level_1).merge_into(level_0)
      end.to raise_error(StandardError, 'Cannot merge into level zero')

      # Numbers should not have changed.
      expect(level_1.reload.number).to eq(1)
    end
  end
end
