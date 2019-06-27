require 'rails_helper'

describe Levels::DeleteService do
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

  RSpec.shared_examples "delete a level" do |level_number|
    let(:chosen_level) { Level.find_by(number: level_number) }
    let!(:previous_level) { chosen_level.course.levels.find_by(number: (level_number - 1)) }

    it 'links startups and target groups in chosen level to previous level' do
      chosen_level_startups = chosen_level.startups.pluck(:id)
      chosen_level_target_groups = chosen_level.target_groups.pluck(:id)

      subject.new(chosen_level).execute

      expect(previous_level.startups.where(id: chosen_level_startups).count).to eq(chosen_level_startups.count)
      expect(previous_level.target_groups.where(id: chosen_level_target_groups).count).to eq(chosen_level_target_groups.count)
    end

    it 'removes entry for the chosen level' do
      subject.new(chosen_level).execute

      expect { chosen_level.reload }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe '#execute' do
    context 'when level 3 is deleted' do
      include_examples 'delete a level', 3
    end

    context 'when level 2 is deleted' do
      include_examples 'delete a level', 2

      it 'renumbers level 3 as level 2' do
        subject.new(chosen_level).execute

        # Number should have changed...
        expect(level_3.reload.number).to eq(2)

        # ...but links should be preserved.
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
