require 'rails_helper'

describe Startups::PerformanceService do
  subject { described_class.new }

  let!(:level_1) { create :level, :one }

  # create startups in the same level
  let!(:startup_1) { create :startup, level: level_1 }
  let!(:startup_2) { create :startup, level: level_1 }
  let!(:startup_3) { create :startup, level: level_1 }

  # The week starts at Monday 6 PM IST and ends at Monday 5:59:59 IST for leaderboard calculation.
  # Set 'week_starting_at' for weekly_karma_point accordingly to generate correct leaderboard
  week_starting_at = DatesService.last_week_start_date

  # assign weekly karma points to the startups
  let!(:week_karma_point_of_startup_1) { create :weekly_karma_point, startup: startup_1, level: level_1, points: 50, week_starting_at: week_starting_at }
  let!(:week_karma_point_of_startup_2) { create :weekly_karma_point, startup: startup_2, level: level_1, points: 60, week_starting_at: week_starting_at }
  let!(:week_karma_point_of_startup_3) { create :weekly_karma_point, startup: startup_3, level: level_1, points: 70, week_starting_at: week_starting_at }

  describe '#leaderboard_rank' do
    it 'returns the leaderboard rank of the specified startup' do
      expect(subject.leaderboard_rank(startup_3)).to eq(1)
      expect(subject.leaderboard_rank(startup_2)).to eq(2)
      expect(subject.leaderboard_rank(startup_1)).to eq(3)
    end
  end

  describe '#last_week_karma' do
    it 'returns the karma points earned last week by the specified startup' do
      expect(subject.last_week_karma(startup_1)).to eq(50)
      expect(subject.last_week_karma(startup_2)).to eq(60)
      expect(subject.last_week_karma(startup_3)).to eq(70)
    end
  end

  describe '#relative_performance' do
    it 'returns a relative measure of performance for the startup specified' do
      expect(subject.relative_performance(startup_1)).to eq(30)
      expect(subject.relative_performance(startup_2)).to eq(50)
      expect(subject.relative_performance(startup_3)).to eq(70)
    end
  end
end
