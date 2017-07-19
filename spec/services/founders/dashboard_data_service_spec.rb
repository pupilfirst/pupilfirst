require 'rails_helper'

describe Founders::DashboardDataService do
  subject { described_class.new(founder) }

  let!(:level_0) { create :level, :zero }
  let!(:level_1) { create :level, :one }
  let!(:level_2) { create :level, :two }
  let!(:startup) { create :startup, level: level_0 }
  let!(:founder) { create :founder, startup: startup }
  let!(:target_group_0) { create :target_group, level: level_0, milestone: true }
  let!(:target_group_1) { create :target_group, level: level_1, milestone: true }
  let!(:target_group_2) { create :target_group, level: level_2, milestone: true }
  let!(:level_0_vanilla_targets) { create_list :target, 2, target_group: target_group_0 }
  let!(:level_1_vanilla_targets) { create_list :target, 2, target_group: target_group_1 }
  let!(:level_2_vanilla_targets) { create_list :target, 2, target_group: target_group_2 }
  let!(:level_0_chores) { create_list :target, 2, chore: true, target_group: nil, level: level_0 }
  let!(:level_1_chores) { create_list :target, 2, chore: true, target_group: nil, level: level_1 }
  let!(:level_2_chores) { create_list :target, 2, chore: true, target_group: nil, level: level_2 }
  let!(:level_0_sessions) { create_list :target, 2, session_at: Time.now, target_group: nil, level: level_0 }
  let!(:level_1_sessions) { create_list :target, 2, session_at: Time.now, target_group: nil, level: level_1 }
  let!(:level_2_sessions) { create_list :target, 2, session_at: Time.now, target_group: nil, level: level_2 }

  describe '#levels' do
    context 'when the startup is in level 0' do
      it 'responds with all targets in level 0' do
        expect(subject.levels).to eq(level_details(level_0))
      end
    end

    context 'when the startup is in a level n > 1' do
      it 'responds with all targets in level 1 to n' do
        startup.update!(level: level_2)
        expect(subject.levels).to eq(level_details(level_1).merge(level_details(level_2)))
      end
    end
  end

  describe '#chores' do
    context 'when the startup is in level 0' do
      it 'responds with all chores in level 0' do
        expected_chore_details = level_0_chores.map { |chore| chore_details(chore) }
        expect(subject.chores).to match_array(expected_chore_details)
      end
    end

    context 'when the startup is in a level n > 1' do
      it 'responds with all chores in level 1 to n' do
        startup.update!(level: level_2)
        expected_chore_details = (level_1_chores + level_2_chores).map { |chore| chore_details(chore) }
        expect(subject.chores).to match_array(expected_chore_details)
      end
    end
  end

  describe '#sessions' do
    context 'when the startup is in level 0' do
      it 'responds with all sessions in level 0' do
        expected_session_details = level_0_sessions.map { |session| session_details(session.reload) }
        expected_session_details = expected_session_details.sort_by { |e| e['id'] }
        actual_sessions = subject.sessions.sort_by { |s| s['id'] }
        expect(actual_sessions).to eq(expected_session_details)
      end
    end

    context 'when the startup is in a level n > 1' do
      it 'responds with all sessions in level 1 to n' do
        startup.update!(level: level_2)
        expected_session_details = (level_1_sessions + level_2_sessions).map { |session| session_details(session.reload) }
        expected_session_details = expected_session_details.sort_by { |e| e['id'] }
        actual_sessions = subject.sessions.sort_by { |s| s['id'] }
        expect(actual_sessions).to eq(expected_session_details)
      end
    end
  end

  def level_details(level)
    {
      level.number => {
        name: level.name,
        target_groups: level.target_groups.map { |target_group| target_group_details(target_group) }
      }
    }
  end

  def target_group_details(target_group)
    {
      'id' => target_group.id,
      'name' => target_group.name,
      'description' => target_group.description,
      'milestone' => target_group.milestone,
      'targets' => target_group.targets.where.not(target_group_id: nil).order(:sort_index).map { |target| target_details(target) }
    }
  end

  def target_details(target)
    result = target.as_json(
      only: subject.send(:target_fields),
      methods: %i[has_rubric target_type target_type_description],
      include: {
        assigner: {
          only: %i[id name]
        }
      }
    )

    # append more details
    result['status'] = :pending

    result
  end

  def chore_details(chore)
    result = target_details(chore)
    result['level'] = { 'number' => chore.level.number }

    result
  end

  def session_details(session)
    result = chore_details(session)
    result['taggings'] = []

    result
  end
end
