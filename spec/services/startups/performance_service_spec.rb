require 'rails_helper'

describe Startups::PerformanceService do
  subject { described_class.new }

  let!(:batch) { create :batch, :with_startups, start_date: 12.days.ago }

  SAMPLE_POINTS = [10, 200, 210, 210, 240, 280, 500, 1000].freeze

  before do
    # add karma points to some startups
    SAMPLE_POINTS.each.with_index(1) do |points, index|
      startup = batch.startups.order(:id).limit(index).last
      create :karma_point, :for_last_week, startup: startup, points: points
    end
  end

  describe '#leaderboard' do
    it 'returns the leaderboard rank list for the batch' do
      expected_ranks = [8, 7, 5, 5, 4, 3, 2, 1, 9, 9]
      expected_leaderboard = batch.startups.order(:id).each_with_index.map { |id, index| [id, expected_ranks[index], SAMPLE_POINTS[index] || 0] }

      expect(subject.leaderboard(batch).sort).to eq(expected_leaderboard)
    end
  end

  describe '#leaderboard_rank' do
    it 'returns the leaderboard rank of the specified startup' do
      expect(subject.leaderboard_rank(batch.startups.first)).to eq(8)
    end
  end

  describe '#last_week_karma' do
    it 'returns the karma points earned last week by the specified startup' do
      expect(subject.last_week_karma(batch.startups.second)).to eq(200)
      expect(subject.last_week_karma(batch.startups.last)).to eq(0)
    end
  end

  describe '#relative_performance' do
    it 'returns a relative measure of performance for the startup specified' do
      startups = batch.startups.order(:id)

      expect(subject.relative_performance(startups.first)).to eq(30)
      expect(subject.relative_performance(startups.fifth)).to eq(50)
      expect(subject.relative_performance(startups.limit(8).last)).to eq(90)
    end
  end
end
