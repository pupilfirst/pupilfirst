require 'rails_helper'

describe Startups::LeaderboardService do
  subject { described_class }

  # Create two levels to check leaderboards created for each level.
  let!(:level_1) { create :level, :one }
  let!(:level_2) { create :level, :two }

  # Create startups for each level
  let!(:startup_1) { create :startup, level: level_1 }
  let!(:startup_2) { create :startup, level: level_1 }
  let!(:startup_3) { create :startup, level: level_1 }

  let!(:startup_4) { create :startup, level: level_2 }
  let!(:startup_5) { create :startup, level: level_2 }
  let!(:startup_6) { create :startup, level: level_2 }

  # Create weekly_karma_point for startups for 1 week ago and 2 weeks ago.
  # The week starts at Monday 6 PM IST and ends at Monday 5:59:59 IST for leaderboard calculation.
  # Set 'week_starting_at' for weekly_karma_point accordingly to generate correct leaderboard
  let(:one_week_ago) { DatesService.last_week_start_date }
  let(:two_weeks_ago) { one_week_ago - 7.days }

  let!(:wkp_2_weeks_ago_startup_1) { create :weekly_karma_point, startup: startup_1, level: level_1, points: 80, week_starting_at: two_weeks_ago }
  let!(:wkp_2_weeks_ago_startup_2) { create :weekly_karma_point, startup: startup_2, level: level_1, points: 60, week_starting_at: two_weeks_ago }
  let!(:wkp_2_weeks_ago_startup_3) { create :weekly_karma_point, startup: startup_3, level: level_1, points: 90, week_starting_at: two_weeks_ago }

  context 'when karma points exist for a week ago' do
    # Weekly karma points for level 1 startups
    let!(:wkp_last_week_startup_1) { create :weekly_karma_point, startup: startup_1, level: level_1, points: 50, week_starting_at: one_week_ago }
    let!(:wkp_last_week_startup_2) { create :weekly_karma_point, startup: startup_2, level: level_1, points: 60, week_starting_at: one_week_ago }
    let!(:wkp_last_week_startup_3) { create :weekly_karma_point, startup: startup_3, level: level_1, points: 70, week_starting_at: one_week_ago }

    # Weekly karma points for level 2 startups.
    # No points are created for startup_6 to check their absence in leaderboard.
    # No points created for level 2 startups for week starting 2 weeks ago to check change in rank to be 0.
    let!(:wkp_last_week_startup_4) { create :weekly_karma_point, startup: startup_4, level: level_2, points: 50, week_starting_at: one_week_ago }
    let!(:wkp_last_week_startup_5) { create :weekly_karma_point, startup: startup_5, level: level_2, points: 60, week_starting_at: one_week_ago }

    before do
      # Expected leaderboards based on weekly karma points
      @leaderboard_for_level_1 = [[startup_3, 1, 70], [startup_2, 2, 60], [startup_1, 3, 50]]
      @leaderboard_for_level_2 = [[startup_5, 1, 60], [startup_4, 2, 50]]

      @leaderboard_with_change_in_rank_l1 = [[startup_3, 1, 70, 0], [startup_2, 2, 60, 1], [startup_1, 3, 50, -1]]
      @leaderboard_with_change_in_rank_l2 = [[startup_5, 1, 60, 0], [startup_4, 2, 50, 0]]
    end

    describe '#leaderboard' do
      it 'returns the leaderboard of the specified level' do
        expect(subject.new(level_1).leaderboard).to eq(@leaderboard_for_level_1)
        expect(subject.new(level_2).leaderboard).to eq(@leaderboard_for_level_2)
      end
    end

    describe '#leaderboard_with_change_in_rank' do
      it 'returns the leaderboard of the specified level with change in rank compared to previous week' do
        expect(subject.new(level_1).leaderboard_with_change_in_rank).to eq(@leaderboard_with_change_in_rank_l1)
        expect(subject.new(level_2).leaderboard_with_change_in_rank).to eq(@leaderboard_with_change_in_rank_l2)
      end
    end

    describe '.pending' do
      it 'return false' do
        expect(subject.pending?).to eq(false)
      end
    end
  end

  context 'when karma points for last week do not exist' do
    describe '.pending' do
      it 'return false' do
        expect(subject.pending?).to eq(true)
      end
    end
  end
end
