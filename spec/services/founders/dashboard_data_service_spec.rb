require 'rails_helper'

describe Founders::DashboardDataService do
  subject { described_class.new(founder) }

  let!(:level_0) { create :level, :zero }
  let!(:level_1) { create :level, :one }
  let!(:level_2) { create :level, :two }
  let!(:level_3) { create :level, :three }
  let!(:startup) { create :startup, level: level_0 }
  let!(:founder) { create :founder, startup: startup }
  let!(:track_1) { create :track }
  let!(:track_2) { create :track }
  let!(:target_group_l0_1) { create :target_group, level: level_0, milestone: true }
  let!(:target_group_l0_2) { create :target_group, level: level_0 }
  let!(:target_group_l1_1) { create :target_group, level: level_1, milestone: true, track: track_1 }
  let!(:target_group_l1_2) { create :target_group, level: level_1, track: track_2 }
  let!(:target_group_l2_1) { create :target_group, level: level_2, milestone: true, track: track_1 }
  let!(:target_group_l2_2) { create :target_group, level: level_2, track: track_2 }
  let!(:level_0_target) { create :target, target_group: target_group_l0_1 }
  let!(:level_0_session) { create :target, session_at: 1.day.ago, target_group: target_group_l0_2 }
  let!(:level_1_target) { create :target, target_group: target_group_l1_1 }
  let!(:level_1_session) { create :target, session_at: 1.day.ago, target_group: target_group_l1_2 }
  let!(:level_2_target) { create :target, target_group: target_group_l2_1 }
  let!(:level_2_session) { create :target, session_at: 1.day.ago, target_group: target_group_l2_2 }

  describe '#props' do
    context 'when startup is in level 0' do
      it 'restricts data to level 0' do
        expected_target_groups = [
          target_group_l0_1.slice(target_group_fields).merge(level: { id: level_0.id }),
          target_group_l0_2.slice(target_group_fields).merge(level: { id: level_0.id })
        ]

        expected_targets = [
          level_0_target.slice(target_fields).merge(additional_target_fields(level_0_target, target_group_l0_1)),
          level_0_session.slice(target_fields).merge(additional_target_fields(level_0_session, target_group_l0_2))
        ]

        props = subject.props

        expect(props.keys).to contain_exactly(:faculty, :levels, :targetGroups, :targets, :tracks)
        expect(props[:faculty]).to match_array(Faculty.team.all.as_json(only: %i[id name], methods: %i[image_url]))
        expect(props[:levels]).to match_array(level_fields(level_0, level_1, level_2, level_3))
        expect(props[:targetGroups]).to match_array(expected_target_groups)
        expect(props[:targets]).to match_array(expected_targets)
        expect(props[:tracks]).to match_array(track_fields(track_1, track_2))
      end
    end

    context 'when startup is in level N > 1' do
      let(:startup) { create :startup, level: level_2 }

      it 'leaves out data from level 0, and includes up to level N' do
        expected_target_groups = [
          target_group_l1_1.slice(target_group_fields).merge(track: { id: track_1.id }, level: { id: level_1.id }),
          target_group_l1_2.slice(target_group_fields).merge(track: { id: track_2.id }, level: { id: level_1.id }),
          target_group_l2_1.slice(target_group_fields).merge(track: { id: track_1.id }, level: { id: level_2.id }),
          target_group_l2_2.slice(target_group_fields).merge(track: { id: track_2.id }, level: { id: level_2.id })
        ]

        expected_targets = [
          level_1_target.slice(target_fields).merge(additional_target_fields(level_1_target, target_group_l1_1)),
          level_1_session.slice(target_fields).merge(additional_target_fields(level_1_session, target_group_l1_2)),
          level_2_target.slice(target_fields).merge(additional_target_fields(level_2_target, target_group_l2_1)),
          level_2_session.slice(target_fields).merge(additional_target_fields(level_2_session, target_group_l2_2))
        ]

        props = subject.props

        expect(props.keys).to contain_exactly(:faculty, :levels, :targetGroups, :targets, :tracks)
        expect(props[:faculty]).to match_array(Faculty.team.all.as_json(only: %i[id name], methods: %i[image_url]))
        expect(props[:levels]).to match_array(level_fields(level_1, level_2, level_3))
        expect(props[:targetGroups]).to match_array(expected_target_groups)
        expect(props[:targets]).to match_array(expected_targets)
        expect(props[:tracks]).to match_array(track_fields(track_1, track_2))
      end
    end
  end

  def level_fields(*levels)
    levels.map do |level|
      level.slice(:id, :name, :number)
    end
  end

  def track_fields(*tracks)
    tracks.map do |track|
      track.slice(:id, :name, :sort_index)
    end
  end

  def target_group_fields
    %i[id name description sort_index milestone]
  end

  def additional_target_fields(target, target_group)
    { target_group: { id: target_group.id }, faculty: { id: target.faculty.id }, status: :pending, prerequisites: nil }
  end

  def target_fields
    %i[id role title description completion_instructions resource_url slideshow_embed timeline_event_type_id days_to_complete points_earnable sort_index session_at video_embed link_to_complete submittability archived youtube_video_id session_by call_to_action]
  end
end
